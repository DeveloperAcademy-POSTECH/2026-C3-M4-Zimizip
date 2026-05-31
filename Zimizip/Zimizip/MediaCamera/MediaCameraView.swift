//
//  MediaCameraView.swift
//  Zimizip
//
//  Created by Mason's Mac on 5/31/26.
//

import AVFoundation
import Combine
import SwiftUI

struct MediaCameraView: View {
    @StateObject private var camera = CameraPreviewModel()

    var body: some View {
        ZStack {
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            if camera.cameraAccessDenied || camera.cameraErrorMessage != nil {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)

                    Text(camera.cameraErrorMessage ?? "카메라 권한이 없어 프리뷰를 표시할 수 없습니다.")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
            }
        }
        .background(Color.black)
        .task {
            await camera.prepareCameraPreview()
        }
        .onDisappear {
            camera.stopSession()
        }
    }
}

final class CameraPreviewModel: ObservableObject {
    let session = AVCaptureSession()

    @Published private(set) var cameraAccessDenied = false
    @Published private(set) var cameraErrorMessage: String?

    private let sessionQueue = DispatchQueue(label: "com.zimizip.camera.session")
    private var isSessionConfigured = false

    func prepareCameraPreview() async {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSessionIfNeeded()
        case .notDetermined:
            let granted = await requestCameraAccess()
            await MainActor.run {
                self.cameraAccessDenied = !granted
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
                self.isSessionConfigured = true
                self.session.commitConfiguration()

                Task { @MainActor in
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

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else {
                return
            }

            self.session.stopRunning()
        }
    }

    private func updateErrorMessage(_ message: String) {
        Task { @MainActor in
            cameraErrorMessage = message
        }
    }
}

private struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewContainerView {
        let view = PreviewContainerView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        uiView.previewLayer.session = session
    }
}

private final class PreviewContainerView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

#Preview {
    MediaCameraView()
}
