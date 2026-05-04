import SwiftUI
import AVFoundation
import Vision
import UIKit

struct DrillCameraView: View {
    let drill: Drill
    var onFinish: (URL?, Int) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var recorder = DrillVideoRecorder()
    @State private var elapsed: Int = 0
    @State private var hasCamera: Bool = DrillVideoRecorder.deviceHasCamera()
    @State private var permissionDenied: Bool = false
    @State private var lastClipURL: URL?
    @State private var hitFlash: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if hasCamera {
                CameraPreviewLayer(session: recorder.session)
                    .ignoresSafeArea()

                PoseOverlay(joints: recorder.joints, connections: recorder.connections)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            } else {
                placeholder
            }

            if hitFlash {
                Color.green.opacity(0.25)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            VStack {
                topBar
                Spacer()
                hudOverlay
                Spacer()
                bottomControls
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .preferredColorScheme(.dark)
        .task {
            guard hasCamera else { return }
            let granted = await recorder.requestPermissions()
            if !granted { permissionDenied = true; return }
            recorder.configure()
            recorder.start()
        }
        .onChange(of: recorder.hits) { _, newValue in
            if newValue > 0 {
                withAnimation(.easeOut(duration: 0.15)) { hitFlash = true }
                Task {
                    try? await Task.sleep(for: .milliseconds(180))
                    withAnimation(.easeIn(duration: 0.25)) { hitFlash = false }
                }
            }
            if newValue >= drill.targetHits, recorder.isRecording {
                finishAndDismiss()
            }
        }
        .onDisappear {
            recorder.tearDown()
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                if recorder.isRecording {
                    recorder.stopRecording { _ in }
                }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.ultraThinMaterial, in: Circle())
            }
            Spacer()
            HStack(spacing: 8) {
                Circle()
                    .fill(recorder.isRecording ? .red : Color.white.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .opacity(recorder.isRecording ? 1 : 0.6)
                Text(recorder.isRecording ? "REC \(timeString)" : "READY")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: recorder.poseDetected ? "figure.strengthtraining.traditional" : "person.slash")
                    .font(.system(size: 11))
                    .foregroundStyle(recorder.poseDetected ? AppTheme.neonGreen : .white.opacity(0.6))
                Text(recorder.poseDetected ? "TRACKING" : "NO POSE")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
        }
    }

    private var hudOverlay: some View {
        VStack(spacing: 14) {
            Text(drill.title)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(radius: 6)
            HStack(spacing: 14) {
                hudChip(label: "HITS", value: "\(recorder.hits)/\(drill.targetHits)", highlight: true)
                hudChip(label: "TIME", value: timeString)
                hudChip(label: "REWARD", value: "+\(drill.coinReward)")
            }
            Text(recorder.isRecording ? "Stand back so the camera sees your full body. Auto-detecting reps." : "Frame yourself fully and tap record.")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.horizontal, 8)
    }

    private func hudChip(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(highlight ? AppTheme.neonGreen : .white)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(highlight ? AppTheme.neonGreen.opacity(0.6) : .clear, lineWidth: 1)
        )
    }

    private var bottomControls: some View {
        VStack(spacing: 14) {
            if permissionDenied {
                Text("Camera access denied. Enable it in Settings to record drills.")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(.black.opacity(0.5), in: .rect(cornerRadius: 10))
            }

            HStack(spacing: 18) {
                Button {
                    recorder.manualHit()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                        Text("HIT").font(.system(size: 9, weight: .bold)).tracking(2)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(.ultraThinMaterial, in: Circle())
                }
                .sensoryFeedback(.impact(weight: .heavy), trigger: recorder.hits)

                Button {
                    if recorder.isRecording {
                        finishAndDismiss()
                    } else {
                        recorder.startRecording()
                        startTimer()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 84, height: 84)
                        RoundedRectangle(cornerRadius: recorder.isRecording ? 8 : 36)
                            .fill(.red)
                            .frame(width: recorder.isRecording ? 36 : 70, height: recorder.isRecording ? 36 : 70)
                            .animation(.spring(response: 0.3), value: recorder.isRecording)
                    }
                }
                .disabled(!hasCamera || permissionDenied)
                .sensoryFeedback(.impact(weight: .medium), trigger: recorder.isRecording)

                Button {
                    finishAndDismiss()
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                        Text("DONE").font(.system(size: 9, weight: .bold)).tracking(2)
                    }
                    .foregroundStyle(AppTheme.neonGreen)
                    .frame(width: 70, height: 70)
                    .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }

    private func finishAndDismiss() {
        let finalHits = recorder.hits
        if recorder.isRecording {
            recorder.stopRecording { url in
                lastClipURL = url
                onFinish(url, finalHits)
                dismiss()
            }
        } else {
            onFinish(lastClipURL, finalHits)
            dismiss()
        }
    }

    private var placeholder: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.5))
            Text("Camera Unavailable")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(.white)
            Text("Install this app on your device via the Rork App to use the camera and auto-track your drills.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var timeString: String {
        let m = elapsed / 60
        let s = elapsed % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        elapsed = 0
        Task {
            while recorder.isRecording {
                try? await Task.sleep(for: .seconds(1))
                elapsed += 1
            }
        }
    }
}

// MARK: - Pose overlay

private struct PoseOverlay: View {
    let joints: [CGPoint]
    let connections: [(Int, Int)]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(Array(connections.enumerated()), id: \.offset) { _, pair in
                    if pair.0 < joints.count, pair.1 < joints.count {
                        let a = joints[pair.0]
                        let b = joints[pair.1]
                        if isValid(a) && isValid(b) {
                            Path { p in
                                p.move(to: scaled(a, in: geo.size))
                                p.addLine(to: scaled(b, in: geo.size))
                            }
                            .stroke(AppTheme.neonGreen.opacity(0.85), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .shadow(color: AppTheme.neonGreen.opacity(0.6), radius: 4)
                        }
                    }
                }

                ForEach(0..<joints.count, id: \.self) { i in
                    if isValid(joints[i]) {
                        Circle()
                            .fill(AppTheme.neonGreen)
                            .frame(width: 8, height: 8)
                            .shadow(color: AppTheme.neonGreen, radius: 4)
                            .position(scaled(joints[i], in: geo.size))
                    }
                }
            }
        }
    }

    private func isValid(_ p: CGPoint) -> Bool {
        p.x.isFinite && p.y.isFinite && !(p.x == 0 && p.y == 0)
    }

    private func scaled(_ p: CGPoint, in size: CGSize) -> CGPoint {
        // Vision normalized point (origin bottom-left). Convert to view coords.
        CGPoint(x: p.x * size.width, y: (1 - p.y) * size.height)
    }
}

private struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.videoLayer.session = session
        view.videoLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

private final class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}

// MARK: - Recorder with Vision pose tracking

@Observable
@MainActor
final class DrillVideoRecorder: NSObject {
    let session = AVCaptureSession()
    var isRecording: Bool = false
    var hits: Int = 0
    var poseDetected: Bool = false
    var joints: [CGPoint] = Array(repeating: .zero, count: 17)
    let connections: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3),         // head/neck
        (1, 4), (4, 5), (5, 6),         // left arm
        (1, 7), (7, 8), (8, 9),         // right arm
        (1, 10), (10, 11), (11, 12),    // left leg
        (1, 13), (13, 14), (14, 15)     // right leg
    ]

    private let movieOutput = AVCaptureMovieFileOutput()
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "drill.video.queue")
    private var pendingCompletion: ((URL?) -> Void)?
    private var configured = false

    // Motion analysis state (only mutated on videoQueue)
    nonisolated(unsafe) private var lastWristY: CGFloat?
    nonisolated(unsafe) private var lastWristTime: TimeInterval = 0
    nonisolated(unsafe) private var lastHitTime: TimeInterval = 0
    nonisolated(unsafe) private var velocityWindow: [CGFloat] = []

    static func deviceHasCamera() -> Bool {
        AVCaptureDevice.default(for: .video) != nil
    }

    func requestPermissions() async -> Bool {
        let videoStatus = AVCaptureDevice.authorizationStatus(for: .video)
        let videoOK: Bool
        switch videoStatus {
        case .authorized: videoOK = true
        case .notDetermined: videoOK = await AVCaptureDevice.requestAccess(for: .video)
        default: videoOK = false
        }
        guard videoOK else { return false }

        let audioStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch audioStatus {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .audio)
        default: return true
        }
    }

    func configure() {
        guard !configured else { return }
        session.beginConfiguration()
        session.sessionPreset = .high

        if let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: camera),
           session.canAddInput(input) {
            session.addInput(input)
        }

        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device: mic),
           session.canAddInput(micInput) {
            session.addInput(micInput)
        }

        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }

        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }
        session.commitConfiguration()
        configured = true
    }

    func start() {
        guard !session.isRunning else { return }
        Task.detached { [session] in
            session.startRunning()
        }
    }

    func tearDown() {
        if movieOutput.isRecording { movieOutput.stopRecording() }
        if session.isRunning {
            Task.detached { [session] in session.stopRunning() }
        }
    }

    func startRecording() {
        guard configured, !movieOutput.isRecording else { return }
        hits = 0
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = dir.appendingPathComponent("drill_\(UUID().uuidString).mov")
        movieOutput.startRecording(to: url, recordingDelegate: self)
        isRecording = true
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard movieOutput.isRecording else {
            completion(nil)
            return
        }
        pendingCompletion = completion
        movieOutput.stopRecording()
    }

    func manualHit() {
        hits += 1
    }

    fileprivate func processPose(_ observation: VNHumanBodyPoseObservation) {
        guard let recognized = try? observation.recognizedPoints(.all) else { return }

        let jointOrder: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .neck, .leftEye, .rightEye,
            .leftShoulder, .leftElbow, .leftWrist,
            .rightShoulder, .rightElbow, .rightWrist,
            .leftHip, .leftKnee, .leftAnkle,
            .rightHip, .rightKnee, .rightAnkle,
            .root
        ]

        var newJoints: [CGPoint] = []
        for name in jointOrder {
            if let pt = recognized[name], pt.confidence > 0.3 {
                newJoints.append(CGPoint(x: pt.location.x, y: pt.location.y))
            } else {
                newJoints.append(.zero)
            }
        }

        // Take dominant wrist (whichever has higher confidence)
        let lw = recognized[.leftWrist]
        let rw = recognized[.rightWrist]
        let bestWrist: CGPoint? = {
            let lc = lw?.confidence ?? 0
            let rc = rw?.confidence ?? 0
            if lc < 0.3 && rc < 0.3 { return nil }
            if lc >= rc, let p = lw { return CGPoint(x: p.location.x, y: p.location.y) }
            if let p = rw { return CGPoint(x: p.location.x, y: p.location.y) }
            return nil
        }()

        let now = CACurrentMediaTime()
        let detectedHit = analyzeWristMotion(wrist: bestWrist, time: now)

        Task { @MainActor [newJoints, detectedHit] in
            self.joints = newJoints
            self.poseDetected = newJoints.contains { $0 != .zero }
            if detectedHit && self.isRecording {
                self.hits += 1
            }
        }
    }

    nonisolated private func analyzeWristMotion(wrist: CGPoint?, time: TimeInterval) -> Bool {
        // Note: we mutate state here from the video queue only.
        guard let w = wrist else {
            return false
        }
        defer {
            lastWristY = w.y
            lastWristTime = time
        }

        guard let prevY = lastWristY, lastWristTime > 0 else {
            return false
        }
        let dt = time - lastWristTime
        guard dt > 0.005, dt < 0.2 else { return false }

        let vy = abs(w.y - prevY) / CGFloat(dt) // normalized units / second

        velocityWindow.append(vy)
        if velocityWindow.count > 6 { velocityWindow.removeFirst() }

        // Threshold tuned for normalized coordinates: > 2.0 ≈ rapid swing
        let cooldown: TimeInterval = 0.55
        if vy > 2.0, time - lastHitTime > cooldown {
            lastHitTime = time
            return true
        }
        return false
    }
}

extension DrillVideoRecorder: @preconcurrency AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        Task { @MainActor in
            self.isRecording = false
            self.pendingCompletion?(error == nil ? outputFileURL : nil)
            self.pendingCompletion = nil
        }
    }
}

extension DrillVideoRecorder: @preconcurrency AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
        do {
            try handler.perform([request])
            if let observation = request.results?.first {
                Task { @MainActor in
                    self.processPose(observation)
                }
            } else {
                Task { @MainActor in
                    self.poseDetected = false
                }
            }
        } catch {
            // ignore frame
        }
    }
}
