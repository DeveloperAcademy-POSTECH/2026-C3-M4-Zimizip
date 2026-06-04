import AVFoundation
import Combine

final class CameraPreviewModel: ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var isFlashEnabled = false
    @Published private(set) var currentCameraPosition: AVCaptureDevice.Position = .back

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.preview.session")
    private let photoOutput = AVCapturePhotoOutput()

    private var isSessionConfigured = false
    private var videoDeviceInput: AVCaptureDeviceInput?

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

    func toggleFlash() {
        guard photoOutput.supportedFlashModes.contains(.on) else {
            return
        }

        isFlashEnabled.toggle()
    }

    func switchCamera() {
        sessionQueue.async { [weak self] in
            guard let self, self.isSessionConfigured else {
                return
            }

            let nextPosition: AVCaptureDevice.Position = self.currentCameraPosition == .back ? .front : .back

            guard
                let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: nextPosition),
                let newInput = try? AVCaptureDeviceInput(device: newCamera)
            else {
                return
            }

            self.session.beginConfiguration()

            if let currentInput = self.videoDeviceInput {
                self.session.removeInput(currentInput)
            }

            guard self.session.canAddInput(newInput) else {
                if let currentInput = self.videoDeviceInput, self.session.canAddInput(currentInput) {
                    self.session.addInput(currentInput)
                }
                self.session.commitConfiguration()
                return
            }

            self.session.addInput(newInput)
            self.videoDeviceInput = newInput
            self.session.commitConfiguration()

            Task { @MainActor in
                self.currentCameraPosition = nextPosition
            }
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
            self.videoDeviceInput = input

            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
            }

            self.isSessionConfigured = true
            self.session.commitConfiguration()

            Task { @MainActor in
                self.currentCameraPosition = .back
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
}
