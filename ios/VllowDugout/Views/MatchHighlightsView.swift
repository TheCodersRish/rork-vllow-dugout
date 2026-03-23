import AVFoundation
import AVKit
import PhotosUI
import SwiftUI

struct MatchHighlightsView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var videoURL: URL?
    @State private var isAccessingSecurity = false

    @State private var events: [HighlightEvent] = []
    @State private var isAnalyzing = false
    @State private var progress: Double = 0
    @State private var errorMessage: String?
    @State private var statusText = "Pick a match recording. Everything runs on your iPhone — no upload."

    @State private var player: AVPlayer?
    @State private var playingEventID: UUID?
    @State private var timeObserverToken: Any?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                PhotosPicker(selection: $pickerItem, matching: .videos) {
                    HStack(spacing: 12) {
                        Image(systemName: "film.stack")
                            .font(.system(size: 22))
                            .foregroundStyle(AppTheme.neonGreen)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Choose cricket video")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("From your photo library")
                                .font(.system(size: 13))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .padding(18)
                    .background(AppTheme.cardSurface)
                    .clipShape(.rect(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
                }
                .disabled(isAnalyzing)

                if isAnalyzing {
                    VStack(alignment: .leading, spacing: 10) {
                        ProgressView(value: progress, total: 1.0)
                            .tint(AppTheme.neonGreen)
                        Text("Analyzing audio & scoreboard… \(Int(progress * 100))%")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.cardSurfaceLight)
                    .clipShape(.rect(cornerRadius: 14))
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.orange)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardSurface)
                        .clipShape(.rect(cornerRadius: 14))
                }

                if let url = videoURL, let p = player, playingEventID != nil {
                    VideoPlayer(player: p)
                        .frame(height: 220)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
                }

                if !events.isEmpty {
                    Text("DETECTED HIGHLIGHTS")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(2)
                        .foregroundStyle(AppTheme.textSecondary)

                    LazyVStack(spacing: 12) {
                        ForEach(events) { event in
                            highlightRow(event)
                        }
                    }
                } else if !isAnalyzing, videoURL != nil, errorMessage == nil {
                    Text("No strong peaks found. Try a broadcast with crowd noise, or a louder clip.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .scrollIndicators(.hidden)
        .background(AppTheme.darkBg)
        .navigationTitle("Match highlights")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.darkBg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onChange(of: pickerItem) { _, new in
            Task { await loadAndAnalyze(new) }
        }
        .onDisappear {
            stopPlayback()
            stopSecurityScopedAccess()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.circle.fill")
                    .foregroundStyle(AppTheme.neonGreen)
                Text("ON-DEVICE HIGHLIGHTS")
                    .font(.system(size: 10, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Text(statusText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.neonGreenDim)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.neonGreen.opacity(0.25), lineWidth: 0.5))
    }

    private func highlightRow(_ event: HighlightEvent) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Peak \(event.peakFormatted)")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(AppTheme.textPrimary)
                    if event.ocrHintMatched {
                        Text("OCR")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(AppTheme.neonGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.neonGreen.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                Text(event.label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                Text("Clip \(event.clipRangeFormatted)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)
            }
            Spacer()
            Button {
                play(event)
            } label: {
                Text(playingEventID == event.id ? "Playing" : "Play")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 0.07, green: 0.07, blue: 0.06))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(AppTheme.neonGreen)
                    .clipShape(Capsule())
            }
            .disabled(videoURL == nil)
        }
        .padding(16)
        .background(AppTheme.cardSurface)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.border, lineWidth: 0.5))
    }

    private func loadAndAnalyze(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        stopPlayback()
        events = []
        errorMessage = nil
        isAnalyzing = true
        progress = 0
        statusText = "Loading video from your library…"

        do {
            guard let movie = try await item.loadTransferable(type: Movie.self) else {
                throw NSError(domain: "MatchHighlights", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not load video"])
            }
            stopSecurityScopedAccess()
            isAccessingSecurity = movie.url.startAccessingSecurityScopedResource()
            videoURL = movie.url

            let asset = AVURLAsset(url: movie.url)
            statusText = "Loudness peaks + Vision OCR on the bottom 20% every 2s. Clips are 7s before → 3s after each peak. All local."

            let result = try await CricketHighlightAnalyzer.analyze(asset: asset) { p in
                progress = p
            }
            events = result
            if result.isEmpty {
                statusText = "Analysis finished — no highlights passed the threshold. Try another clip."
            } else {
                statusText = "Found \(result.count) candidate moment(s). Tap Play for a 10s preview."
            }
        } catch {
            errorMessage = error.localizedDescription
            statusText = "Something went wrong."
        }

        isAnalyzing = false
    }

    private func play(_ event: HighlightEvent) {
        guard let url = videoURL else { return }
        stopPlayback()

        let p = AVPlayer(url: url)
        player = p
        playingEventID = event.id

        p.seek(to: CMTime(seconds: event.clipStartSeconds, preferredTimescale: 600)) { _ in
            p.play()
        }

        let end = event.clipEndSeconds
        let interval = CMTime(seconds: 0.08, preferredTimescale: 600)
        timeObserverToken = p.addPeriodicTimeObserver(forInterval: interval, queue: .main) { t in
            if CMTimeGetSeconds(t) >= end {
                p.pause()
                playingEventID = nil
            }
        }
    }

    private func stopPlayback() {
        if let token = timeObserverToken, let p = player {
            p.removeTimeObserver(token)
        }
        timeObserverToken = nil
        player?.pause()
        player = nil
        playingEventID = nil
    }

    private func stopSecurityScopedAccess() {
        if isAccessingSecurity, let url = videoURL {
            url.stopAccessingSecurityScopedResource()
        }
        isAccessingSecurity = false
    }
}

#Preview {
    MatchHighlightsView()
}
