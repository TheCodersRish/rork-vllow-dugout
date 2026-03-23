@preconcurrency import AVFoundation
import Foundation
@preconcurrency import Vision

/// On-device highlight detection: loudness peaks + scoreboard OCR (Vision). No network.
/// `nonisolated` avoids default `MainActor` isolation (see `SWIFT_DEFAULT_ACTOR_ISOLATION`) so AVFoundation/Vision compile cleanly.
enum CricketHighlightAnalyzer {

    private static let windowSeconds: Double = 0.1
    private static let hopSeconds: Double = 0.05
    private static let ocrIntervalSeconds: Double = 2.0
    private static let peakMergeSeconds: Double = 2.0
    private static let ocrAlignWindow: Double = 2.0
    private static let clipLeadSeconds: Double = 7.0
    private static let clipTrailSeconds: Double = 3.0

    /// `progress` is 0...1. `@MainActor` avoids Sendable issues with SwiftUI `@State` updates.
    nonisolated static func analyze(
        asset: AVAsset,
        progress: @escaping @MainActor (Double) -> Void
    ) async throws -> [HighlightEvent] {
        let duration = try await asset.load(.duration)
        let durationSec = max(CMTimeGetSeconds(duration), 0.1)

        await progress(0.05)

        let mono = try await extractMonoSamples(
            asset: asset,
            progress: progress,
            progressBase: 0.05,
            progressScale: 0.45
        )

        await progress(0.5)

        let sampleRate = max(Double(mono.count) / durationSec, 8000)
        let peaks = detectAudioPeaks(mono: mono, sampleRate: sampleRate, durationSec: durationSec)

        await progress(0.55)

        let ocrHits = try await scanScoreboardOCR(
            asset: asset,
            durationSec: durationSec,
            progress: progress
        )

        await progress(0.98)

        var merged = mergePeaks(peaks, minSpacing: peakMergeSeconds)
        if merged.isEmpty {
            let ocrTimes = ocrHits.filter { $0.match }.map(\.time).sorted()
            merged = mergePeaks(ocrTimes, minSpacing: 4.0)
        }

        var events: [HighlightEvent] = []

        for peak in merged {
            let ocrNear = ocrHits.contains { abs($0.time - peak) <= ocrAlignWindow && $0.match }
            let label: String
            if ocrNear && !peaks.isEmpty {
                label = "Crowd + scoreboard cue"
            } else if ocrNear && peaks.isEmpty {
                label = "Scoreboard text (OCR)"
            } else {
                label = "Audio spike (crowd / replay / FX)"
            }

            let start = max(0, peak - clipLeadSeconds)
            let end = min(durationSec, peak + clipTrailSeconds)
            guard end > start else { continue }

            events.append(
                HighlightEvent(
                    id: UUID(),
                    peakTimeSeconds: peak,
                    clipStartSeconds: start,
                    clipEndSeconds: end,
                    label: label,
                    ocrHintMatched: ocrNear
                )
            )
        }

        await progress(1.0)
        return events.sorted { $0.peakTimeSeconds < $1.peakTimeSeconds }
    }

    // MARK: - Audio

    private nonisolated static func extractMonoSamples(
        asset: AVAsset,
        progress: @escaping @MainActor (Double) -> Void,
        progressBase: Double,
        progressScale: Double
    ) async throws -> [Float] {
        let tracks = try await asset.loadTracks(withMediaType: .audio)
        guard let track = tracks.first else { return [] }

        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        output.alwaysCopiesSampleData = false
        guard reader.canAdd(output) else {
            throw NSError(domain: "CricketHighlightAnalyzer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot read audio"])
        }
        reader.add(output)

        guard reader.startReading() else {
            throw reader.error ?? NSError(domain: "CricketHighlightAnalyzer", code: 2, userInfo: nil)
        }

        var mono: [Float] = []
        mono.reserveCapacity(48000 * 120)

        var bytesRead: Int = 0
        let estBytes = 10_000_000
        var channels: Int = 2

        while reader.status == .reading {
            guard let sb = output.copyNextSampleBuffer(),
                  let block = CMSampleBufferGetDataBuffer(sb) else { break }

            if let fmt = CMSampleBufferGetFormatDescription(sb),
               let desc = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                let ch = Int(desc.pointee.mChannelsPerFrame)
                if ch > 0 { channels = ch }
            }

            var lengthAtOffset = 0
            var totalLength = 0
            var dataPointer: UnsafeMutablePointer<Int8>?
            guard CMBlockBufferGetDataPointer(block, atOffset: 0, lengthAtOffsetOut: &lengthAtOffset, totalLengthOut: &totalLength, dataPointerOut: &dataPointer) == kCMBlockBufferNoErr,
                  let base = dataPointer else { continue }

            let sampleCount = totalLength / 2
            base.withMemoryRebound(to: Int16.self, capacity: sampleCount) { ptr in
                let buf = UnsafeBufferPointer(start: ptr, count: sampleCount)
                var i = 0
                let ch = max(1, channels)
                while i + ch - 1 < sampleCount {
                    var acc: Float = 0
                    for c in 0..<ch {
                        acc += Float(buf[i + c]) / 32_768.0
                    }
                    mono.append(acc / Float(ch))
                    i += ch
                }
            }

            bytesRead += totalLength
            if bytesRead % 500_000 < totalLength {
                let frac = min(1.0, Double(bytesRead) / Double(estBytes))
                await progress(progressBase + frac * progressScale)
            }
        }

        return mono
    }

    private nonisolated static func detectAudioPeaks(mono: [Float], sampleRate: Double, durationSec: Double) -> [Double] {
        guard !mono.isEmpty else { return [] }

        let windowLen = max(Int(sampleRate * windowSeconds), 256)
        let hopLen = max(Int(sampleRate * hopSeconds), 128)

        var rmsDb: [Float] = []
        rmsDb.reserveCapacity(mono.count / hopLen + 2)

        var idx = 0
        while idx + windowLen <= mono.count {
            var sum: Float = 0
            for j in idx..<(idx + windowLen) {
                let s = mono[j]
                sum += s * s
            }
            let rms = sqrt(sum / Float(windowLen))
            let db = 20 * log10(max(rms, 1e-10))
            rmsDb.append(db)
            idx += hopLen
        }

        guard !rmsDb.isEmpty else { return [] }

        let sorted = rmsDb.sorted()
        let q85 = sorted[Int(Double(sorted.count - 1) * 0.85)]
        let q50 = sorted[Int(Double(sorted.count - 1) * 0.5)]
        let threshold = q50 + (q85 - q50) * 1.35

        var peakIndices: [Int] = []
        for i in 1..<(rmsDb.count - 1) where rmsDb[i] > threshold && rmsDb[i] >= rmsDb[i - 1] && rmsDb[i] >= rmsDb[i + 1] {
            peakIndices.append(i)
        }

        let secPerBin = Double(hopLen) / sampleRate
        return peakIndices.map { Double($0) * secPerBin }
    }

    private nonisolated static func mergePeaks(_ peaks: [Double], minSpacing: Double) -> [Double] {
        let sorted = peaks.sorted()
        var clusters: [[Double]] = []
        for p in sorted {
            if var last = clusters.last, let first = last.first, p - first < minSpacing {
                last.append(p)
                clusters[clusters.count - 1] = last
            } else {
                clusters.append([p])
            }
        }
        return clusters.map { $0.max() ?? 0 }.filter { $0 > 0 }
    }

    // MARK: - Vision OCR

    private struct OCRHit: Sendable {
        let time: Double
        let match: Bool
    }

    private nonisolated static func scanScoreboardOCR(
        asset: AVAsset,
        durationSec: Double,
        progress: @escaping @MainActor (Double) -> Void
    ) async throws -> [OCRHit] {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero

        var hits: [OCRHit] = []
        var t: Double = 0
        let step = ocrIntervalSeconds
        var n = 0
        let totalSteps = max(1, Int(ceil(durationSec / step)))

        while t < durationSec - 0.05 {
            let cm = CMTime(seconds: t, preferredTimescale: 600)
            let cgImage: CGImage
            do {
                cgImage = try await generator.image(at: cm).image
            } catch {
                t += step
                continue
            }

            let cropped = cropBottomFraction(cgImage, fraction: 0.2)
            let match = try recognizeScoreboardText(in: cropped)
            hits.append(OCRHit(time: t, match: match))

            n += 1
            let frac = Double(n) / Double(totalSteps)
            await progress(0.55 + frac * 0.4)
            t += step
        }

        return hits
    }

    private nonisolated static func cropBottomFraction(_ image: CGImage, fraction: Double) -> CGImage {
        let w = image.width
        let h = image.height
        let cropH = max(1, Int(Double(h) * fraction))
        // CGImage space: origin bottom-left — bottom strip is low y
        let rect = CGRect(x: 0, y: 0, width: CGFloat(w), height: CGFloat(cropH))
        return image.cropping(to: rect) ?? image
    }

    private nonisolated static func recognizeScoreboardText(in image: CGImage) throws -> Bool {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        let strings = request.results?.compactMap { $0 as? VNRecognizedTextObservation }.flatMap { obs in
            obs.topCandidates(1).map(\.string)
        } ?? []

        let combined = strings.joined(separator: " ")
        return scoreboardHeuristic(combined)
    }

    private nonisolated static func scoreboardHeuristic(_ text: String) -> Bool {
        let lower = text.lowercased()
        if lower.contains("wkt") || lower.contains("wicket") { return true }
        if lower.range(of: #"\d+\s*/\s*\d+"#, options: .regularExpression) != nil { return true }
        if lower.range(of: #"\b[46]\b"#, options: .regularExpression) != nil { return true }
        if text.contains("/") && text.rangeOfCharacter(from: .decimalDigits) != nil { return true }
        return false
    }
}
