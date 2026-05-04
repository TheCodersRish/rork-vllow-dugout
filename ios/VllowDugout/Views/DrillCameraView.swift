import SwiftUI
import AVFoundation
import UIKit

struct DrillCameraView: View {
    let drill: Drill
    var onFinish: (URL?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var recorder = DrillVideoRecorder()
    @State private var elapsed: Int = 0
    @State private var hits: Int = 0
    @State private var hasCamera: Bool = DrillVideoRecorder.deviceHasCamera()
    @State private var permissionDenied: Bool = false
    @State private var lastClipURL: URL?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if hasCamera {
                CameraPreviewLayer(session: recorder.session)
                    .ignoresSafeArea()
            } else {
                placeholder
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
            Color.clear.frame(width: 40, height: 40)
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
                hudChip(label: "HITS", value: "\(hits)/\(drill.targetHits)")
                hudChip(label: "TARGET", value: drill.durationFormatted)
                hudChip(label: "REWARD", value: "+\(drill.coinReward)")
            }
        }
        .padding(.horizontal, 8)
    }

    private func hudChip(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
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
                    hits += 1
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
                .sensoryFeedback(.impact(weight: .heavy), trigger: hits)

                Button {
                    if recorder.isRecording {
                        recorder.stopRecording { url in
                            lastClipURL = url
                            onFinish(url)
                            dismiss()
                        }
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
                    if recorder.isRecording {
                        recorder.stopRecording { url in
                            lastClipURL = url
                        }
                    }
                    onFinish(lastClipURL)
                    dismiss()
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

    private var placeholder: some View {
        VStack(spacing: 18) {
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.5))
            Text("Camera Unavailable")
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(.white)
            Text("Install this app on your device via the Rork App to use the camera and record drills.")
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

@Observable
@MainActor
final class DrillVideoRecorder: NSObject {
    let session = AVCaptureSession()
    var isRecording: Bool = false
    private let movieOutput = AVCaptureMovieFileOutput()
    private var pendingCompletion: ((URL?) -> Void)?
    private var configured = false

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
