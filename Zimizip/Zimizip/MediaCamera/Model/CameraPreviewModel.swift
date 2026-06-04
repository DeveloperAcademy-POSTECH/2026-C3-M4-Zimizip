import AVFoundation
import Combine

final class CameraPreviewModel: ObservableObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.preview.session")
    private var isSessionConfigured = false

    func prepareCameraPreview() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSessionIfNeeded()
        case .notDetermined:
            let granted = await requestCameraAccess()

            if granted {
                configureSessionIfNeeded()
            }
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else {
                return
            }

            self.session.stopRunning()
        }
    }

    private func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func configureSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard !self.isSessionConfigured else {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            guard
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: camera),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(input)
            self.isSessionConfigured = true
            self.session.commitConfiguration()

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
}
