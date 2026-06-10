import AVFoundation
import CoreImage
import Foundation
import ReplayKit
import UIKit

final class SampleBufferReactionVideoRecorder: NSObject, VideoRecording {
    private let screenRecorder = RPScreenRecorder.shared()
    private let captureSession = AVCaptureSession()
    private let captureSessionQueue = DispatchQueue(label: "com.zimizip.reaction.sample-buffer.camera-session")
    private let cameraOutputQueue = DispatchQueue(label: "com.zimizip.reaction.sample-buffer.camera-output")
    private let writingQueue = DispatchQueue(label: "com.zimizip.reaction.sample-buffer.writer")
    private let ciContext = CIContext()

    private var latestCameraImage: CIImage?
    private var latestCameraPresentationTime: CMTime?

    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var outputURL: URL?
    private var firstVideoPresentationTime: CMTime?
    private var hasLoggedFirstAudioSample = false
    private var outputSize: CGSize = .zero
    private var isRecording = false
    private var isCaptureSessionConfigured = false
    private var pendingStartContinuation: CheckedContinuation<Void, Error>?
    private var pendingStopContinuation: CheckedContinuation<URL, Error>?

    func startRecording() async throws {
        guard !isRecording else { return }
        guard screenRecorder.isAvailable else { throw SampleBufferReactionVideoRecorderError.recordingUnavailable }

        print("[ReactionRecord] SampleBufferReactionVideoRecorder.startRecording requested")
        try await requestCameraAccessIfNeeded()
        print("[ReactionRecord] camera access ready")
        try await configureCaptureSessionIfNeeded()
        print("[ReactionRecord] camera session configured")

        let outputURL = makeReactionRecordingURL()
        try? FileManager.default.removeItem(at: outputURL)

        self.outputURL = outputURL
        latestCameraImage = nil
        latestCameraPresentationTime = nil
        firstVideoPresentationTime = nil
        hasLoggedFirstAudioSample = false
        assetWriter = nil
        videoInput = nil
        audioInput = nil
        pixelBufferAdaptor = nil

        try await startCameraSession()
        print("[ReactionRecord] camera session started")
        try await startReplayKitCapture()
        print("[ReactionRecord] ReplayKit sample capture started")

        isRecording = true
        print("[ReactionRecord] SampleBufferReactionVideoRecorder started")
    }

    func stopRecording() async throws -> URL {
        guard isRecording else { throw SampleBufferReactionVideoRecorderError.notRecording }

        try await stopReplayKitCapture()
        stopCameraSession()

        let recordedURL = try await finishWriting()
        isRecording = false

        let fileSize = fileSizeDescription(at: recordedURL)
        print("[ReactionRecord] sample buffer reaction video ready: \(recordedURL.lastPathComponent), size: \(fileSize)")

        return recordedURL
    }
}

private extension SampleBufferReactionVideoRecorder {
    func requestCameraAccessIfNeeded() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("[ReactionRecord] camera access already authorized")
            return
        case .notDetermined:
            print("[ReactionRecord] requesting camera access")
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }

            guard granted else { throw SampleBufferReactionVideoRecorderError.cameraAccessDenied }
            print("[ReactionRecord] camera access granted")
        case .denied, .restricted:
            throw SampleBufferReactionVideoRecorderError.cameraAccessDenied
        @unknown default:
            throw SampleBufferReactionVideoRecorderError.cameraAccessDenied
        }
    }

    func configureCaptureSessionIfNeeded() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            captureSessionQueue.async { [weak self] in
                guard let self else { return }
                guard !self.isCaptureSessionConfigured else {
                    continuation.resume()
                    return
                }

                self.captureSession.beginConfiguration()
                self.captureSession.sessionPreset = .high

                do {
                    try self.addFrontCameraInput()
                    try self.addVideoDataOutput()
                    self.captureSession.commitConfiguration()
                    self.isCaptureSessionConfigured = true
                    continuation.resume()
                } catch {
                    self.captureSession.commitConfiguration()
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func addFrontCameraInput() throws {
        guard let camera = preferredFrontCamera() else {
            throw SampleBufferReactionVideoRecorderError.frontCameraUnavailable
        }

        let input = try AVCaptureDeviceInput(device: camera)

        guard captureSession.canAddInput(input) else {
            throw SampleBufferReactionVideoRecorderError.cannotConfigureCamera
        }

        captureSession.addInput(input)
    }

    func preferredFrontCamera() -> AVCaptureDevice? {
        if let ultraWideCamera = AVCaptureDevice.default(
            .builtInUltraWideCamera,
            for: .video,
            position: .front
        ) {
            print("[ReactionRecord] sample buffer front ultra wide camera selected")
            return ultraWideCamera
        }

        if let wideCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) {
            print("[ReactionRecord] sample buffer front wide camera selected")
            return wideCamera
        }

        return nil
    }

    func addVideoDataOutput() throws {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        videoOutput.setSampleBufferDelegate(self, queue: cameraOutputQueue)

        guard captureSession.canAddOutput(videoOutput) else {
            throw SampleBufferReactionVideoRecorderError.cannotConfigureCamera
        }

        captureSession.addOutput(videoOutput)

        if let videoConnection = videoOutput.connection(with: .video) {
            videoConnection.isVideoMirrored = true
            videoConnection.videoRotationAngle = 90
        }
    }

    func startCameraSession() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            captureSessionQueue.async { [weak self] in
                guard let self else { return }
                guard !self.captureSession.isRunning else {
                    continuation.resume()
                    return
                }

                self.captureSession.startRunning()
                continuation.resume()
            }
        }
    }

    func stopCameraSession() {
        captureSessionQueue.async { [weak self] in
            guard let self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    func startReplayKitCapture() async throws {
        print("[ReactionRecord] ReplayKit startCapture requested")
        screenRecorder.isCameraEnabled = false
        screenRecorder.isMicrophoneEnabled = true

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Task { @MainActor [weak self] in
                guard let self else { return }

                self.screenRecorder.startCapture { [weak self] sampleBuffer, sampleBufferType, error in
                    if let error {
                        print("[ReactionRecord] ReplayKit sample capture error: \(error.localizedDescription)")
                        return
                    }

                    switch sampleBufferType {
                    case .video:
                        self?.handleScreenSampleBuffer(sampleBuffer)
                    case .audioMic:
                        self?.handleAudioSampleBuffer(sampleBuffer)
                    default:
                        break
                    }
                } completionHandler: { error in
                    if let error {
                        print("[ReactionRecord] ReplayKit startCapture failed: \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                        return
                    }

                    print("[ReactionRecord] ReplayKit startCapture completion succeeded")
                    continuation.resume()
                }
            }
        }
    }

    func stopReplayKitCapture() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            screenRecorder.stopCapture { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume()
            }
        }
    }

    func handleScreenSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let screenPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        writingQueue.async { [weak self] in
            guard let self else { return }

            do {
                try self.prepareWriterIfNeeded(
                    screenPixelBuffer: screenPixelBuffer,
                    presentationTime: presentationTime
                )
                try self.appendCompositedFrame(
                    screenPixelBuffer: screenPixelBuffer,
                    presentationTime: presentationTime
                )
            } catch {
                print("[ReactionRecord] sample buffer append failed: \(error.localizedDescription)")
            }
        }
    }

    func handleAudioSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        writingQueue.async { [weak self] in
            guard let self,
                  let firstVideoPresentationTime = self.firstVideoPresentationTime,
                  let audioInput = self.audioInput,
                  audioInput.isReadyForMoreMediaData else {
                return
            }

            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
            guard presentationTime >= firstVideoPresentationTime else {
                return
            }

            if !self.hasLoggedFirstAudioSample {
                self.hasLoggedFirstAudioSample = true
                print("[ReactionRecord] first mic audio sample appended at: \(presentationTime.seconds)")
            }

            let didAppend = audioInput.append(sampleBuffer)
            if !didAppend {
                print("[ReactionRecord] mic audio sample append failed")
            }
        }
    }

    func prepareWriterIfNeeded(
        screenPixelBuffer: CVPixelBuffer,
        presentationTime: CMTime
    ) throws {
        guard assetWriter == nil else { return }
        guard let outputURL else { throw SampleBufferReactionVideoRecorderError.missingOutputURL }

        let width = CVPixelBufferGetWidth(screenPixelBuffer)
        let height = CVPixelBufferGetHeight(screenPixelBuffer)
        outputSize = CGSize(width: width, height: height)

        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        let input = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
        )
        input.expectsMediaDataInRealTime = true

        let audioInput = AVAssetWriterInput(
            mediaType: .audio,
            outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: 44_100,
                AVEncoderBitRateKey: 128_000
            ]
        )
        audioInput.expectsMediaDataInRealTime = true

        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )

        guard writer.canAdd(input) else {
            throw SampleBufferReactionVideoRecorderError.cannotConfigureWriter
        }

        writer.add(input)

        if writer.canAdd(audioInput) {
            writer.add(audioInput)
            self.audioInput = audioInput
            print("[ReactionRecord] sample buffer writer added audio input")
        } else {
            print("[ReactionRecord] sample buffer writer could not add audio input")
        }

        writer.startWriting()
        writer.startSession(atSourceTime: presentationTime)

        assetWriter = writer
        videoInput = input
        pixelBufferAdaptor = adaptor
        firstVideoPresentationTime = presentationTime

        print("[ReactionRecord] sample buffer writer started at: \(presentationTime.seconds), size: \(width)x\(height)")
    }

    func appendCompositedFrame(
        screenPixelBuffer: CVPixelBuffer,
        presentationTime: CMTime
    ) throws {
        guard let videoInput,
              let pixelBufferAdaptor,
              let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool,
              videoInput.isReadyForMoreMediaData else {
            return
        }

        var outputPixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &outputPixelBuffer)

        guard let outputPixelBuffer else {
            throw SampleBufferReactionVideoRecorderError.cannotCreatePixelBuffer
        }

        let compositedImage = makeCompositedImage(screenPixelBuffer: screenPixelBuffer)
        ciContext.render(compositedImage, to: outputPixelBuffer)
        pixelBufferAdaptor.append(outputPixelBuffer, withPresentationTime: presentationTime)
    }

    func makeCompositedImage(screenPixelBuffer: CVPixelBuffer) -> CIImage {
        let screenImage = CIImage(cvPixelBuffer: screenPixelBuffer)

        guard let latestCameraImage else {
            return screenImage
                .transformed(toFill: outputSize)
                .cropped(to: CGRect(origin: .zero, size: outputSize))
        }

        let backgroundImage = latestCameraImage
            .transformed(toFill: outputSize)
            .cropped(to: CGRect(origin: .zero, size: outputSize))

        let overlayWidth = outputSize.width / 4
        let overlayHeight = overlayWidth * outputSize.height / outputSize.width
        let overlaySize = CGSize(width: overlayWidth, height: overlayHeight)
        let overlayOrigin = CGPoint(
            x: outputSize.width - overlayWidth - 20,
            y: outputSize.height - overlayHeight - 20
        )

        let overlayImage = screenImage
            .transformed(toFill: overlaySize)
            .cropped(to: CGRect(origin: .zero, size: overlaySize))
            .transformed(by: CGAffineTransform(translationX: overlayOrigin.x, y: overlayOrigin.y))

        return overlayImage.composited(over: backgroundImage)
    }

    func finishWriting() async throws -> URL {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            writingQueue.async { [weak self] in
                guard let self,
                      let assetWriter = self.assetWriter,
                      let videoInput = self.videoInput,
                      let outputURL = self.outputURL else {
                    continuation.resume(throwing: SampleBufferReactionVideoRecorderError.notRecording)
                    return
                }

                videoInput.markAsFinished()
                self.audioInput?.markAsFinished()
                assetWriter.finishWriting {
                    if let error = assetWriter.error {
                        continuation.resume(throwing: error)
                        return
                    }

                    continuation.resume(returning: outputURL)
                }
            }
        }
    }

    func makeReactionRecordingURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("sample-buffer-reaction-video-\(UUID().uuidString)")
            .appendingPathExtension("mp4")
    }

    func fileSizeDescription(at url: URL) -> String {
        guard let fileSize = try? FileManager.default
            .attributesOfItem(atPath: url.path)[.size] as? NSNumber else {
            return "unknown"
        }

        let bytes = fileSize.doubleValue
        return String(format: "%.1f MB (%lld bytes)", bytes / 1_000_000, fileSize.int64Value)
    }
}

extension SampleBufferReactionVideoRecorder: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let cameraImage = normalizedCameraImage(from: pixelBuffer)
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        writingQueue.async { [weak self] in
            self?.latestCameraImage = cameraImage
            self?.latestCameraPresentationTime = presentationTime
        }
    }

    nonisolated func normalizedCameraImage(from pixelBuffer: CVPixelBuffer) -> CIImage {
        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)

        guard cameraImage.extent.width > cameraImage.extent.height else {
            return cameraImage
        }

        return cameraImage.oriented(.right)
    }
}

private extension CIImage {
    func transformed(toFill size: CGSize) -> CIImage {
        guard extent.width > 0, extent.height > 0, size.width > 0, size.height > 0 else {
            return self
        }

        let scale = max(size.width / extent.width, size.height / extent.height)
        let scaledImage = transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let originX = (size.width - scaledImage.extent.width) / 2 - scaledImage.extent.minX
        let originY = (size.height - scaledImage.extent.height) / 2 - scaledImage.extent.minY

        return scaledImage.transformed(
            by: CGAffineTransform(translationX: originX, y: originY)
        )
    }
}

enum SampleBufferReactionVideoRecorderError: LocalizedError {
    case cameraAccessDenied
    case recordingUnavailable
    case frontCameraUnavailable
    case cannotConfigureCamera
    case cannotConfigureWriter
    case cannotCreatePixelBuffer
    case missingOutputURL
    case notRecording

    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "전면 카메라 권한이 필요합니다."
        case .recordingUnavailable:
            return "화면 녹화를 사용할 수 없습니다."
        case .frontCameraUnavailable:
            return "전면 카메라를 사용할 수 없습니다."
        case .cannotConfigureCamera:
            return "전면 카메라 캡처를 준비할 수 없습니다."
        case .cannotConfigureWriter:
            return "리액션 영상 저장을 준비할 수 없습니다."
        case .cannotCreatePixelBuffer:
            return "리액션 영상 프레임을 만들 수 없습니다."
        case .missingOutputURL:
            return "리액션 영상 저장 위치를 만들 수 없습니다."
        case .notRecording:
            return "리액션 녹화가 진행 중이 아닙니다."
        }
    }
}
