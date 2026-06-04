import AVFoundation
import SwiftUI

struct CameraPreviewSurface: UIViewRepresentable {
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

final class PreviewContainerView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updatePreviewOrientation()
    }

    private func updatePreviewOrientation() {
        guard
            let connection = previewLayer.connection,
            connection.isVideoOrientationSupported,
            let windowScene = window?.windowScene,
            let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: windowScene.interfaceOrientation)
        else {
            return
        }

        connection.videoOrientation = videoOrientation
    }
}

private extension AVCaptureVideoOrientation {
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        default:
            return nil
        }
    }
}
