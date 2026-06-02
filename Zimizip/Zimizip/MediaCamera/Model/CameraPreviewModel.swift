import AVFoundation
import Combine

final class CameraPreviewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var isFlashEnabled = false
    @Published private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    @Published private(set) var currentExposureBias: Float = 0.0
    @Published private(set) var exposureBiasRange: ClosedRange<Float> = -3.0...3.0
    @Published private(set) var selectedColorPreset: CameraColorPreset = .original

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.preview.session")
    private let photoOutput = AVCapturePhotoOutput()

    private var isSessionConfigured = false
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var pendingCaptureCompletion: ((Data?) -> Void)?

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

    func capturePhoto(onPhotoCaptured: @escaping (Data?) -> Void) {
        performPhotoCapture(
            flashMode: isFlashEnabled ? .on : .off,
            onPhotoCaptured: onPhotoCaptured
        )
    }

    func setColorPreset(_ preset: CameraColorPreset) {
        selectedColorPreset = preset
    }

    func setExposureBias(_ value: Float) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()
                let clampedValue = min(max(value, device.minExposureTargetBias), device.maxExposureTargetBias)
                device.setExposureTargetBias(clampedValue)
                device.unlockForConfiguration()

                Task { @MainActor in
                    self.currentExposureBias = clampedValue
                }
            } catch {
                return
            }
        }
    }

    func displayValue(for control: CameraManualControl) -> String {
        switch control {
        case .exposure:
            currentExposureBias == 0
                ? "0.0"
                : String(format: "%+.1f", currentExposureBias)
        case .shutterSpeed:
            CameraManualControl.defaultDisplayValues[control] ?? "AUTO"
        case .iso:
            CameraManualControl.defaultDisplayValues[control] ?? "AUTO"
        case .whiteBalance:
            CameraManualControl.defaultDisplayValues[control] ?? "AWB"
        }
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
            self.refreshDeviceState()

            Task { @MainActor in
                self.currentCameraPosition = nextPosition
            }
        }
    }

    private func performPhotoCapture(
        flashMode: AVCaptureDevice.FlashMode,
        onPhotoCaptured: @escaping (Data?) -> Void
    ) {
        sessionQueue.async { [weak self] in
            guard let self, self.isSessionConfigured else {
                return
            }

            guard self.pendingCaptureCompletion == nil else {
                return
            }

            let settings = AVCapturePhotoSettings()

            if self.photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }

            self.pendingCaptureCompletion = onPhotoCaptured
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    private func requestCameraAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func refreshDeviceState() {
        guard let device = videoDeviceInput?.device else {
            return
        }

        let exposureBiasRange = device.minExposureTargetBias...device.maxExposureTargetBias
        let currentExposureBias = device.exposureTargetBias

        Task { @MainActor in
            self.exposureBiasRange = exposureBiasRange
            self.currentExposureBias = currentExposureBias
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
            self.refreshDeviceState()

            Task { @MainActor in
                self.currentCameraPosition = .back
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    private func finishCapture(with data: Data?) {
        let completion = pendingCaptureCompletion
        pendingCaptureCompletion = nil

        Task { @MainActor in
            completion?(data)
        }
    }
}

extension CameraPreviewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil, let photoData = photo.fileDataRepresentation() else {
            sessionQueue.async { [weak self] in
                self?.finishCapture(with: nil)
            }
            return
        }

        sessionQueue.async { [weak self] in
            self?.finishCapture(with: photoData)
        }
    }
}
