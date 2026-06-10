import AVFoundation
import Combine

final class CameraPreviewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var isFlashEnabled = false
    @Published private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    @Published private(set) var currentExposureBias: Float = 0.0
    @Published private(set) var exposureBiasRange: ClosedRange<Float> = -3.0...3.0
    @Published private(set) var currentISO: Float?
    @Published private(set) var isoRange: ClosedRange<Float> = 50...6400
    @Published private(set) var currentShutterDuration: Double?
    @Published private(set) var shutterRange: ClosedRange<Double> = (1.0 / 1000.0)...(1.0 / 4.0)
    @Published private(set) var whiteBalancePreset: CameraWhiteBalancePreset = .auto
    @Published private(set) var selectedColorPreset: CameraColorPreset = .original
    @Published private(set) var isPreviewSessionActive = false

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.preview.session")
    private let photoOutput = AVCapturePhotoOutput()

    private var isSessionConfigured = false
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var pendingCaptureCompletion: ((Data?) -> Void)?

    func prepareCameraPreviewIfAuthorized() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSessionIfNeeded()
        case .notDetermined, .denied, .restricted:
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

            Task { @MainActor in
                self.isPreviewSessionActive = false
            }
        }
    }

    func toggleFlash() {
        guard photoOutput.supportedFlashModes.contains(.on) else {
            return
        }

        isFlashEnabled.toggle()
    }

    func capturePhoto(
        videoOrientation: AVCaptureVideoOrientation,
        onPhotoCaptured: @escaping (Data?) -> Void
    ) {
        performPhotoCapture(
            videoOrientation: videoOrientation,
            flashMode: isFlashEnabled ? .on : .off,
            onPhotoCaptured: onPhotoCaptured
        )
    }

    func setColorPreset(_ preset: CameraColorPreset) {
        selectedColorPreset = preset
    }

    func resetManualControls() {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()

                let resetExposureBias = min(max(0.0, device.minExposureTargetBias), device.maxExposureTargetBias)
                device.setExposureTargetBias(resetExposureBias)

                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }

                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }

                device.unlockForConfiguration()

                Task { @MainActor in
                    self.currentExposureBias = resetExposureBias
                    self.currentISO = nil
                    self.currentShutterDuration = nil
                    self.whiteBalancePreset = .auto
                }

                self.refreshDeviceState()
            } catch {
                return
            }
        }
    }

    func setWhiteBalancePreset(_ preset: CameraWhiteBalancePreset) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()

                if preset == .auto {
                    if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                        device.whiteBalanceMode = .continuousAutoWhiteBalance
                    }
                } else if
                    let temperature = preset.temperature,
                    device.isWhiteBalanceModeSupported(.locked)
                {
                    let values = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
                        temperature: temperature,
                        tint: 0
                    )
                    let gains = self.normalizedWhiteBalanceGains(
                        for: device.deviceWhiteBalanceGains(for: values),
                        device: device
                    )
                    device.setWhiteBalanceModeLocked(with: gains)
                }

                device.unlockForConfiguration()

                Task { @MainActor in
                    self.whiteBalancePreset = preset
                }
            } catch {
                return
            }
        }
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

    func setShutterAuto() {
        enableAutoExposure()
    }

    func setISOAuto() {
        enableAutoExposure()
    }

    func setISO(_ value: Float) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            let clampedISO = Self.nearestStandardISO(
                to: value,
                in: self.isoRange
            )
            let durationSeconds = self.currentShutterDuration ?? Self.nearestStandardShutterDuration(
                to: CMTimeGetSeconds(device.exposureDuration),
                in: self.shutterRange
            )
            let duration = CMTimeMakeWithSeconds(durationSeconds, preferredTimescale: 1_000_000_000)

            do {
                try device.lockForConfiguration()
                device.setExposureModeCustom(duration: duration, iso: clampedISO)
                device.unlockForConfiguration()
                self.refreshDeviceState()
            } catch {
                return
            }
        }
    }

    func setShutterDuration(_ durationSeconds: Double) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            let clampedDurationSeconds = Self.nearestStandardShutterDuration(
                to: durationSeconds,
                in: self.shutterRange
            )
            let duration = CMTimeMakeWithSeconds(clampedDurationSeconds, preferredTimescale: 1_000_000_000)
            let iso = self.currentISO ?? device.iso

            do {
                try device.lockForConfiguration()
                device.setExposureModeCustom(duration: duration, iso: iso)
                device.unlockForConfiguration()
                self.refreshDeviceState()
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
            currentShutterDuration.map(Self.shutterDisplayString(for:)) ?? "AUTO"
        case .iso:
            currentISO.map(Self.isoDisplayString(for:)) ?? "AUTO"
        case .whiteBalance:
            whiteBalancePreset.shortLabel
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
        videoOrientation: AVCaptureVideoOrientation,
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

            if let connection = self.photoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = videoOrientation
                }

                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = self.currentCameraPosition == .front
                }
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
        let exposureDuration = CMTimeGetSeconds(device.exposureDuration)
        let minimumShutterDuration = max(CMTimeGetSeconds(device.activeFormat.minExposureDuration), 1.0 / 10_000.0)
        let maximumShutterDuration = min(CMTimeGetSeconds(device.activeFormat.maxExposureDuration), 1.0)
        let minimumISO = max(device.activeFormat.minISO, 50)
        let maximumISO = min(device.activeFormat.maxISO, 6400)
        let currentISO = device.exposureMode == .custom ? device.iso : nil
        let currentShutterDuration = device.exposureMode == .custom ? exposureDuration : nil

        Task { @MainActor in
            self.exposureBiasRange = exposureBiasRange
            self.currentExposureBias = currentExposureBias
            self.isoRange = minimumISO...maximumISO
            self.currentISO = currentISO
            self.shutterRange = minimumShutterDuration...maximumShutterDuration
            self.currentShutterDuration = currentShutterDuration
        }
    }

    private func enableAutoExposure() {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()

                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }

                device.unlockForConfiguration()
                self.refreshDeviceState()
            } catch {
                return
            }
        }
    }

    private func normalizedWhiteBalanceGains(
        for gains: AVCaptureDevice.WhiteBalanceGains,
        device: AVCaptureDevice
    ) -> AVCaptureDevice.WhiteBalanceGains {
        AVCaptureDevice.WhiteBalanceGains(
            redGain: min(max(1.0, gains.redGain), device.maxWhiteBalanceGain),
            greenGain: min(max(1.0, gains.greenGain), device.maxWhiteBalanceGain),
            blueGain: min(max(1.0, gains.blueGain), device.maxWhiteBalanceGain)
        )
    }

    nonisolated static func shutterDisplayString(for seconds: Double) -> String {
        guard seconds > 0 else {
            return "AUTO"
        }

        let displaySeconds = nearestStandardShutterDuration(to: seconds)

        if displaySeconds >= 1 {
            return String(format: "%.1fs", displaySeconds)
        }

        return "1/\(Int((1 / displaySeconds).rounded()))"
    }

    nonisolated static func isoDisplayString(for iso: Float) -> String {
        "\(Int(nearestStandardISO(to: iso).rounded()))"
    }

    nonisolated static func nearestStandardISO(
        to iso: Float,
        in range: ClosedRange<Float>? = nil
    ) -> Float {
        let candidates = standardISOs(in: range)
        guard let firstCandidate = candidates.first else {
            return iso
        }

        return candidates.min { lhs, rhs in
            abs(log10(Double(lhs)) - log10(Double(iso))) < abs(log10(Double(rhs)) - log10(Double(iso)))
        } ?? firstCandidate
    }

    nonisolated static func standardISOs(in range: ClosedRange<Float>? = nil) -> [Float] {
        let standardISOs: [Float] = [
            50,
            64,
            80,
            100,
            125,
            160,
            200,
            250,
            320,
            400,
            500,
            640,
            800,
            1000,
            1250,
            1600,
            2000,
            2500,
            3200,
            4000,
            5000,
            6400
        ]

        guard let range else {
            return standardISOs
        }

        let filteredISOs = standardISOs.filter { range.contains($0) }
        guard filteredISOs.isEmpty else {
            return filteredISOs
        }

        return [
            min(max(100, range.lowerBound), range.upperBound)
        ]
    }

    nonisolated static func nearestStandardShutterDuration(
        to seconds: Double,
        in range: ClosedRange<Double>? = nil
    ) -> Double {
        let candidates = standardShutterDurations(in: range)
        guard let firstCandidate = candidates.first else {
            return seconds
        }

        return candidates.min { lhs, rhs in
            abs(log10(lhs) - log10(seconds)) < abs(log10(rhs) - log10(seconds))
        } ?? firstCandidate
    }

    nonisolated static func standardShutterDurations(in range: ClosedRange<Double>? = nil) -> [Double] {
        let standardDurations = [
            1.0 / 16_000.0,
            1.0 / 12_500.0,
            1.0 / 10_000.0,
            1.0 / 8_000.0,
            1.0 / 6_400.0,
            1.0 / 5_000.0,
            1.0 / 4_000.0,
            1.0 / 3_200.0,
            1.0 / 2_500.0,
            1.0 / 2_000.0,
            1.0 / 1_600.0,
            1.0 / 1_250.0,
            1.0 / 1_000.0,
            1.0 / 800.0,
            1.0 / 640.0,
            1.0 / 500.0,
            1.0 / 400.0,
            1.0 / 320.0,
            1.0 / 250.0,
            1.0 / 200.0,
            1.0 / 160.0,
            1.0 / 125.0,
            1.0 / 100.0,
            1.0 / 80.0,
            1.0 / 60.0,
            1.0 / 50.0,
            1.0 / 40.0,
            1.0 / 30.0,
            1.0 / 25.0,
            1.0 / 20.0,
            1.0 / 15.0,
            1.0 / 13.0,
            1.0 / 10.0,
            1.0 / 8.0,
            1.0 / 6.0,
            1.0 / 5.0,
            1.0 / 4.0,
            1.0 / 3.0,
            1.0 / 2.0,
            1.0
        ]

        guard let range else {
            return standardDurations
        }

        let filteredDurations = standardDurations.filter { range.contains($0) }
        guard filteredDurations.isEmpty else {
            return filteredDurations
        }

        return [
            min(max(1.0 / 1_000.0, range.lowerBound), range.upperBound)
        ]
    }

    private func configureSessionIfNeeded() {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard !self.isSessionConfigured else {
                if !self.session.isRunning {
                    self.session.startRunning()
                }
                let isSessionRunning = self.session.isRunning

                Task { @MainActor in
                    self.isPreviewSessionActive = isSessionRunning
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

            let isSessionRunning = self.session.isRunning

            Task { @MainActor in
                self.isPreviewSessionActive = isSessionRunning
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
