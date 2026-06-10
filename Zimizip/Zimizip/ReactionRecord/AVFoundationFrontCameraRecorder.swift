import AVFoundation
import Foundation

final class AVFoundationFrontCameraRecorder: NSObject, VideoRecording {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.zimizip.reaction.front-camera")
    private let movieOutput = AVCaptureMovieFileOutput()

    private var isSessionConfigured = false
    private var isRecording = false
    private var pendingStartContinuation: CheckedContinuation<Void, Error>?
    private var pendingStopContinuation: CheckedContinuation<URL, Error>?

    func startRecording() async throws {
        try await requestCameraAccessIfNeeded()
        try await configureSessionIfNeeded()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else { return }
                guard !self.isRecording else {
                    continuation.resume()
                    return
                }

                let outputURL = self.makeFrontCameraRecordingSourceURL()
                try? FileManager.default.removeItem(at: outputURL)

                if !self.session.isRunning {
                    self.session.startRunning()
                }

                self.pendingStartContinuation = continuation
                self.movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            }
        }
    }

    func stopRecording() async throws -> URL {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else { return }
                guard self.isRecording, self.movieOutput.isRecording else {
                    continuation.resume(throwing: FrontCameraRecorderError.notRecording)
                    return
                }

                self.pendingStopContinuation = continuation
                self.movieOutput.stopRecording()
            }
        }
    }

    private func requestCameraAccessIfNeeded() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    continuation.resume(returning: granted)
                }
            }

            guard granted else { throw FrontCameraRecorderError.cameraAccessDenied }
        case .denied, .restricted:
            throw FrontCameraRecorderError.cameraAccessDenied
        @unknown default:
            throw FrontCameraRecorderError.cameraAccessDenied
        }
    }

    private func configureSessionIfNeeded() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            sessionQueue.async { [weak self] in
                guard let self else { return }
                guard !self.isSessionConfigured else {
                    continuation.resume()
                    return
                }

                self.session.beginConfiguration()
                self.session.sessionPreset = .high

                do {
                    try self.addFrontCameraInput()
                    try self.addMovieOutput()
                    self.isSessionConfigured = true
                    self.session.commitConfiguration()
                    continuation.resume()
                } catch {
                    self.session.commitConfiguration()
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func addFrontCameraInput() throws {
        guard let camera = preferredFrontCamera() else {
            throw FrontCameraRecorderError.frontCameraUnavailable
        }

        let input = try AVCaptureDeviceInput(device: camera)

        guard session.canAddInput(input) else {
            throw FrontCameraRecorderError.cannotConfigureSession
        }

        session.addInput(input)
    }

    private func preferredFrontCamera() -> AVCaptureDevice? {
        if let ultraWideCamera = AVCaptureDevice.default(
            .builtInUltraWideCamera,
            for: .video,
            position: .front
        ) {
            print("[ReactionRecord] front ultra wide camera selected for 0.5x recording")
            return ultraWideCamera
        }

        if let wideCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) {
            print("[ReactionRecord] front ultra wide camera unavailable. fallback to front wide camera")
            return wideCamera
        }

        print("[ReactionRecord] no front camera available")
        return nil
    }

    private func addMovieOutput() throws {
        guard session.canAddOutput(movieOutput) else {
            throw FrontCameraRecorderError.cannotConfigureSession
        }

        session.addOutput(movieOutput)
    }

    private func makeFrontCameraRecordingSourceURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("front-camera-recording-\(UUID().uuidString)")
            .appendingPathExtension("mp4")
    }
}

extension AVFoundationFrontCameraRecorder: AVCaptureFileOutputRecordingDelegate {
    nonisolated func fileOutput(
        _ output: AVCaptureFileOutput,
        didStartRecordingTo fileURL: URL,
        from connections: [AVCaptureConnection]
    ) {
        sessionQueue.async { [weak self] in
            self?.isRecording = true
            self?.pendingStartContinuation?.resume()
            self?.pendingStartContinuation = nil
        }
    }

    nonisolated func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            self.isRecording = false

            if self.session.isRunning {
                self.session.stopRunning()
            }

            if let error {
                self.pendingStopContinuation?.resume(throwing: error)
            } else {
                self.pendingStopContinuation?.resume(returning: outputFileURL)
            }

            self.pendingStopContinuation = nil
        }
    }
}

enum FrontCameraRecorderError: LocalizedError {
    case cameraAccessDenied
    case frontCameraUnavailable
    case cannotConfigureSession
    case notRecording

    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "전면 카메라 권한이 필요합니다."
        case .frontCameraUnavailable:
            return "전면 카메라를 사용할 수 없습니다."
        case .cannotConfigureSession:
            return "전면 카메라 녹화를 준비할 수 없습니다."
        case .notRecording:
            return "전면 카메라 녹화가 진행 중이 아닙니다."
        }
    }
}
