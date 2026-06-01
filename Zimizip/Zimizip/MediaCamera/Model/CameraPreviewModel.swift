import AVFoundation
import Combine
import UIKit

final class CameraPreviewModel: NSObject, ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var cameraAccessDenied = false
    @Published private(set) var cameraErrorMessage: String?
    @Published private(set) var isFlashEnabled = false
    @Published private(set) var currentCameraPosition: AVCaptureDevice.Position = .back
    @Published private(set) var currentExposureBias: Float = 0.0
    @Published private(set) var currentISO: Float?
    @Published private(set) var isoRange: ClosedRange<Float> = 50...6400
    @Published private(set) var currentShutterDuration: Double?
    @Published private(set) var shutterRange: ClosedRange<Double> = (1.0 / 1000.0)...(1.0 / 4.0)
    @Published private(set) var whiteBalancePreset: CameraWhiteBalancePreset = .auto
    @Published private(set) var selectedColorPreset: CameraColorPreset = .original
    @Published private(set) var countdownValue: Int?

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.session")

    private let photoOutput = AVCapturePhotoOutput()

    private var isSessionConfigured = false
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var pendingCaptureAspectRatio: CameraAspectRatioOption = .threeByFour
    private var pendingCaptureCompletion: ((Data?) -> Void)?

    func prepareCameraPreview() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSessionIfNeeded()
        case .notDetermined:
            let granted = await requestCameraAccess()
            await MainActor.run {
                cameraAccessDenied = !granted
            }

            if granted {
                configureSessionIfNeeded()
            }
        case .denied, .restricted:
            await MainActor.run {
                cameraAccessDenied = true
                cameraErrorMessage = "설정에서 카메라 접근을 허용하면 프리뷰를 볼 수 있습니다."
            }
        @unknown default:
            await MainActor.run {
                cameraErrorMessage = "카메라 권한 상태를 확인할 수 없습니다."
            }
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

            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: nextPosition) else {
                self.updateErrorMessage("전환할 카메라를 찾지 못했습니다.")
                return
            }

            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)

                self.session.beginConfiguration()

                if let currentInput = self.videoDeviceInput {
                    self.session.removeInput(currentInput)
                }

                guard self.session.canAddInput(newInput) else {
                    self.session.commitConfiguration()
                    self.updateErrorMessage("카메라 전환에 실패했습니다.")
                    return
                }

                self.session.addInput(newInput)
                self.videoDeviceInput = newInput
                self.session.commitConfiguration()

                self.refreshDeviceState()

                Task { @MainActor in
                    self.currentCameraPosition = nextPosition
                }
            } catch {
                self.session.commitConfiguration()
                self.updateErrorMessage("카메라를 전환하지 못했습니다: \(error.localizedDescription)")
            }
        }
    }

    func capturePhoto(
        using timer: CameraTimerOption,
        aspectRatio: CameraAspectRatioOption,
        onPhotoCaptured: @escaping (Data?) -> Void
    ) {
        guard countdownValue == nil else { return }

        let seconds = timer.seconds

        guard seconds > 0 else {
            performPhotoCapture(
                aspectRatio: aspectRatio,
                onPhotoCaptured: onPhotoCaptured
            )
            return
        }

        Task {
            for remaining in stride(from: seconds, through: 1, by: -1) {
                await MainActor.run {
                    countdownValue = remaining
                }

                try? await Task.sleep(for: .seconds(1))
            }

            await MainActor.run {
                countdownValue = nil
            }

            performPhotoCapture(
                aspectRatio: aspectRatio,
                onPhotoCaptured: onPhotoCaptured
            )
        }
    }

    func setExposureBias(_ value: Float) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            do {
                try device.lockForConfiguration()
                let clamped = min(max(value, device.minExposureTargetBias), device.maxExposureTargetBias)
                device.setExposureTargetBias(clamped)
                device.unlockForConfiguration()
                self.refreshDeviceState()
            } catch {
                self.updateErrorMessage("노출 보정을 적용하지 못했습니다.")
            }
        }
    }

    func setISOAuto() {
        enableAutoExposure()
    }

    func setISO(_ value: Float) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            let clampedISO = min(max(value, self.isoRange.lowerBound), self.isoRange.upperBound)
            let durationSeconds = self.currentShutterDuration ?? max(CMTimeGetSeconds(device.exposureDuration), self.shutterRange.lowerBound)
            let duration = CMTimeMakeWithSeconds(durationSeconds, preferredTimescale: 1_000_000_000)

            do {
                try device.lockForConfiguration()
                device.setExposureModeCustom(duration: duration, iso: clampedISO)
                device.unlockForConfiguration()
                self.refreshDeviceState()
            } catch {
                self.updateErrorMessage("ISO를 변경하지 못했습니다.")
            }
        }
    }

    func setShutterAuto() {
        enableAutoExposure()
    }

    func setShutterDuration(_ durationSeconds: Double) {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            let clampedDurationSeconds = min(max(durationSeconds, self.shutterRange.lowerBound), self.shutterRange.upperBound)
            let duration = CMTimeMakeWithSeconds(clampedDurationSeconds, preferredTimescale: 1_000_000_000)
            let iso = self.currentISO ?? device.iso

            do {
                try device.lockForConfiguration()
                device.setExposureModeCustom(duration: duration, iso: iso)
                device.unlockForConfiguration()
                self.refreshDeviceState()
            } catch {
                self.updateErrorMessage("셔터 속도를 변경하지 못했습니다.")
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
                    let values = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(temperature: temperature, tint: 0)
                    var gains = device.deviceWhiteBalanceGains(for: values)
                    gains = self.normalizedWhiteBalanceGains(for: gains, device: device)
                    device.setWhiteBalanceModeLocked(with: gains)
                }

                device.unlockForConfiguration()

                Task { @MainActor in
                    self.whiteBalancePreset = preset
                }
            } catch {
                self.updateErrorMessage("화이트밸런스를 적용하지 못했습니다.")
            }
        }
    }

    func setColorPreset(_ preset: CameraColorPreset) {
        Task { @MainActor in
            selectedColorPreset = preset
        }
    }

    func resetManualControls() {
        setExposureBias(0.0)
        enableAutoExposure()
        setWhiteBalancePreset(.auto)
    }

    func displayValue(for control: CameraManualControl) -> String {
        switch control {
        case .exposure:
            String(format: "%.1f", currentExposureBias)
        case .shutterSpeed:
            currentShutterDuration.map(Self.shutterDisplayString(for:)) ?? "AUTO"
        case .iso:
            currentISO.map { "\(Int($0.rounded()))" } ?? "AUTO"
        case .whiteBalance:
            whiteBalancePreset == .auto ? "AWB" : whiteBalancePreset.shortLabel
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

    private func performPhotoCapture(
        aspectRatio: CameraAspectRatioOption,
        onPhotoCaptured: @escaping (Data?) -> Void
    ) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard self.pendingCaptureCompletion == nil else {
                return
            }

            let settings = AVCapturePhotoSettings()

            if self.photoOutput.supportedFlashModes.contains(self.isFlashEnabled ? .on : .off) {
                settings.flashMode = self.isFlashEnabled ? .on : .off
            }

            self.pendingCaptureAspectRatio = aspectRatio
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
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            else {
                self.session.commitConfiguration()
                self.updateErrorMessage("사용 가능한 후면 카메라를 찾지 못했습니다.")
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)

                guard self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    self.updateErrorMessage("카메라 입력을 세션에 추가할 수 없습니다.")
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
                    self.cameraAccessDenied = false
                    self.cameraErrorMessage = nil
                }

                if !self.session.isRunning {
                    self.session.startRunning()
                }
            } catch {
                self.session.commitConfiguration()
                self.updateErrorMessage("카메라를 초기화하지 못했습니다: \(error.localizedDescription)")
            }
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
                self.updateErrorMessage("자동 노출 모드로 전환하지 못했습니다.")
            }
        }
    }

    private func refreshDeviceState() {
        sessionQueue.async { [weak self] in
            guard let self, let device = self.videoDeviceInput?.device else {
                return
            }

            let exposureDuration = CMTimeGetSeconds(device.exposureDuration)
            let minimumDuration = max(CMTimeGetSeconds(device.activeFormat.minExposureDuration), 1.0 / 10_000.0)
            let maximumDuration = min(CMTimeGetSeconds(device.activeFormat.maxExposureDuration), 1.0)
            let minimumISO = max(device.activeFormat.minISO, 50)
            let maximumISO = min(device.activeFormat.maxISO, 6400)

            Task { @MainActor in
                self.isoRange = minimumISO...maximumISO
                self.shutterRange = minimumDuration...maximumDuration
                self.currentExposureBias = device.exposureTargetBias
                self.currentISO = device.exposureMode == .custom ? device.iso : nil
                self.currentShutterDuration = device.exposureMode == .custom ? exposureDuration : nil
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

    private func updateErrorMessage(_ message: String) {
        Task { @MainActor in
            cameraErrorMessage = message
        }
    }

    private func finishCapture(with data: Data?) {
        let completion = pendingCaptureCompletion
        pendingCaptureCompletion = nil

        Task { @MainActor in
            completion?(data)
        }
    }

    private func croppedImageData(from photoData: Data, aspectRatio: CameraAspectRatioOption) -> Data? {
        guard
            let sourceImage = UIImage(data: photoData),
            let normalizedImage = normalizedImage(from: sourceImage),
            let cgImage = normalizedImage.cgImage
        else {
            return nil
        }

        let cropRect = aspectRatio.cropRect(
            in: CGSize(width: cgImage.width, height: cgImage.height)
        )

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        let croppedImage = UIImage(cgImage: croppedCGImage)
        return croppedImage.jpegData(compressionQuality: 0.98)
    }

    private func normalizedImage(from image: UIImage) -> UIImage? {
        let pixelSize = image.size

        guard pixelSize.width > 0, pixelSize.height > 0 else {
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: pixelSize, format: format)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: pixelSize))
        }
    }

    static func shutterDisplayString(for seconds: Double) -> String {
        guard seconds > 0 else {
            return "AUTO"
        }

        if seconds >= 1 {
            return String(format: "%.1fs", seconds)
        }

        return "1/\(Int((1 / seconds).rounded()))"
    }
}

extension CameraPreviewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else {
            updateErrorMessage("사진 촬영에 실패했습니다.")
            sessionQueue.async { [weak self] in
                self?.finishCapture(with: nil)
            }
            return
        }

        guard let photoData = photo.fileDataRepresentation() else {
            updateErrorMessage("사진 데이터를 처리하지 못했습니다.")
            sessionQueue.async { [weak self] in
                self?.finishCapture(with: nil)
            }
            return
        }

        sessionQueue.async { [weak self] in
            guard let self else { return }

            let croppedData = self.croppedImageData(
                from: photoData,
                aspectRatio: self.pendingCaptureAspectRatio
            )

            if croppedData == nil {
                self.updateErrorMessage("선택한 화면 비율로 사진을 자르지 못했습니다.")
            }

            self.finishCapture(with: croppedData)
        }
    }
}
