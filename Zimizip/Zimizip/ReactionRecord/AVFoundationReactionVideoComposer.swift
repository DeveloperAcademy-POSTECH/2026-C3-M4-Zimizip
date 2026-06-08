import AVFoundation
import CoreGraphics
import Foundation

final class AVFoundationReactionVideoComposer: ReactionVideoComposing {
    func compose(
        frontCameraVideoURL: URL,
        screenRecordingURL: URL
    ) async throws -> URL {
        let source = try await makeReactionVideoSource(
            frontCameraVideoURL: frontCameraVideoURL,
            screenRecordingURL: screenRecordingURL
        )
        let composition = try await makeComposition(from: source)
        let videoComposition = try await makeVideoComposition(from: source, composition: composition)
        let outputURL = makeComposedReactionVideoURL()

        try? FileManager.default.removeItem(at: outputURL)
        try await export(composition.asset, videoComposition: videoComposition, to: outputURL)

        return outputURL
    }

    private func makeReactionVideoSource(
        frontCameraVideoURL: URL,
        screenRecordingURL: URL
    ) async throws -> ReactionVideoSource {
        let frontCameraAsset = AVURLAsset(url: frontCameraVideoURL)
        let screenRecordingAsset = AVURLAsset(url: screenRecordingURL)
        let frontCameraTrack = try await firstVideoTrack(from: frontCameraAsset)
        let screenRecordingTrack = try await firstVideoTrack(from: screenRecordingAsset)
        let duration = try await compositionDuration(
            frontCameraAsset: frontCameraAsset,
            screenRecordingAsset: screenRecordingAsset
        )

        return ReactionVideoSource(
            frontCameraAsset: frontCameraAsset,
            screenRecordingAsset: screenRecordingAsset,
            frontCameraTrack: frontCameraTrack,
            screenRecordingTrack: screenRecordingTrack,
            duration: duration
        )
    }

    private func makeComposition(
        from source: ReactionVideoSource
    ) async throws -> ReactionVideoComposition {
        let composition = AVMutableComposition()

        let compositionFrontCameraTrack = try addVideoTrack(
            source.frontCameraTrack,
            to: composition,
            duration: source.duration
        )
        let compositionScreenRecordingTrack = try addVideoTrack(
            source.screenRecordingTrack,
            to: composition,
            duration: source.duration
        )

        try await addAudioTrack(
            from: source.frontCameraAsset,
            to: composition,
            duration: source.duration
        )

        return ReactionVideoComposition(
            asset: composition,
            frontCameraTrack: compositionFrontCameraTrack,
            screenRecordingTrack: compositionScreenRecordingTrack
        )
    }

    private func makeVideoComposition(
        from source: ReactionVideoSource,
        composition: ReactionVideoComposition
    ) async throws -> AVVideoComposition {
        let renderSize = try await presentationSize(of: source.frontCameraTrack)
        let screenRecordingSize = try await presentationSize(of: source.screenRecordingTrack)
        let overlayFrame = makeScreenRecordingOverlayFrame(
            renderSize: renderSize,
            screenRecordingSize: screenRecordingSize
        )
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = renderSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        videoComposition.instructions = [
            makeVideoCompositionInstruction(
                duration: source.duration,
                frontCameraTrack: composition.frontCameraTrack,
                frontCameraTransform: try await aspectFillTransform(
                    for: source.frontCameraTrack,
                    renderSize: renderSize
                ),
                screenRecordingTrack: composition.screenRecordingTrack,
                screenRecordingTransform: try await aspectFitTransform(
                    for: source.screenRecordingTrack,
                    targetFrame: overlayFrame
                )
            )
        ]

        return videoComposition
    }

    private func firstVideoTrack(from asset: AVAsset) async throws -> AVAssetTrack {
        guard let track = try await asset.loadTracks(withMediaType: .video).first else {
            throw ReactionVideoComposerError.missingVideoTrack
        }

        return track
    }

    private func compositionDuration(
        frontCameraAsset: AVAsset,
        screenRecordingAsset: AVAsset
    ) async throws -> CMTime {
        let frontCameraDuration = try await frontCameraAsset.load(.duration)
        let screenRecordingDuration = try await screenRecordingAsset.load(.duration)

        return CMTimeMinimum(frontCameraDuration, screenRecordingDuration)
    }

    private func addVideoTrack(
        _ sourceTrack: AVAssetTrack,
        to composition: AVMutableComposition,
        duration: CMTime
    ) throws -> AVMutableCompositionTrack {
        guard
            let compositionTrack = composition.addMutableTrack(
                withMediaType: .video,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
        else {
            throw ReactionVideoComposerError.cannotCreateCompositionTrack
        }

        try compositionTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: sourceTrack,
            at: .zero
        )

        return compositionTrack
    }

    private func addAudioTrack(
        from asset: AVAsset,
        to composition: AVMutableComposition,
        duration: CMTime
    ) async throws {
        guard let sourceAudioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            return
        }

        guard
            let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
        else {
            throw ReactionVideoComposerError.cannotCreateCompositionTrack
        }

        try compositionAudioTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: sourceAudioTrack,
            at: .zero
        )
    }

    private func makeVideoCompositionInstruction(
        duration: CMTime,
        frontCameraTrack: AVCompositionTrack,
        frontCameraTransform: CGAffineTransform,
        screenRecordingTrack: AVCompositionTrack,
        screenRecordingTransform: CGAffineTransform
    ) -> AVMutableVideoCompositionInstruction {
        let frontCameraInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: frontCameraTrack)
        frontCameraInstruction.setTransform(frontCameraTransform, at: .zero)

        let screenRecordingInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: screenRecordingTrack)
        screenRecordingInstruction.setTransform(screenRecordingTransform, at: .zero)

        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        instruction.layerInstructions = [
            screenRecordingInstruction,
            frontCameraInstruction
        ]

        return instruction
    }

    private func presentationSize(of track: AVAssetTrack) async throws -> CGSize {
        let naturalSize = try await track.load(.naturalSize)
        let preferredTransform = try await track.load(.preferredTransform)
        let transformedSize = naturalSize.applying(preferredTransform)

        return CGSize(
            width: abs(transformedSize.width),
            height: abs(transformedSize.height)
        )
    }

    private func makeScreenRecordingOverlayFrame(
        renderSize: CGSize,
        screenRecordingSize: CGSize
    ) -> CGRect {
        let horizontalPadding = renderSize.width * 0.06
        let bottomPadding = renderSize.height * 0.06
        let overlayWidth = renderSize.width / 3
        let overlayHeight = overlayWidth * screenRecordingSize.height / screenRecordingSize.width

        return CGRect(
            x: renderSize.width - overlayWidth - horizontalPadding,
            y: renderSize.height - overlayHeight - bottomPadding,
            width: overlayWidth,
            height: overlayHeight
        )
    }

    private func aspectFillTransform(
        for track: AVAssetTrack,
        renderSize: CGSize
    ) async throws -> CGAffineTransform {
        let presentationSize = try await presentationSize(of: track)
        let preferredTransform = try await track.load(.preferredTransform)
        let scale = max(
            renderSize.width / presentationSize.width,
            renderSize.height / presentationSize.height
        )
        let scaledSize = CGSize(
            width: presentationSize.width * scale,
            height: presentationSize.height * scale
        )
        let translation = CGAffineTransform(
            translationX: (renderSize.width - scaledSize.width) / 2,
            y: (renderSize.height - scaledSize.height) / 2
        )

        return preferredTransform
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(translation)
    }

    private func aspectFitTransform(
        for track: AVAssetTrack,
        targetFrame: CGRect
    ) async throws -> CGAffineTransform {
        let presentationSize = try await presentationSize(of: track)
        let preferredTransform = try await track.load(.preferredTransform)
        let scale = min(
            targetFrame.width / presentationSize.width,
            targetFrame.height / presentationSize.height
        )
        let scaledSize = CGSize(
            width: presentationSize.width * scale,
            height: presentationSize.height * scale
        )
        let translation = CGAffineTransform(
            translationX: targetFrame.midX - scaledSize.width / 2,
            y: targetFrame.midY - scaledSize.height / 2
        )

        return preferredTransform
            .concatenating(CGAffineTransform(scaleX: scale, y: scale))
            .concatenating(translation)
    }

    private func export(
        _ asset: AVAsset,
        videoComposition: AVVideoComposition,
        to outputURL: URL
    ) async throws {
        guard
            let exportSession = AVAssetExportSession(
                asset: asset,
                presetName: AVAssetExportPresetHighestQuality
            )
        else {
            throw ReactionVideoComposerError.cannotCreateExportSession
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.videoComposition = videoComposition

        await exportSession.export()

        if let error = exportSession.error {
            throw error
        }

        guard exportSession.status == .completed else {
            throw ReactionVideoComposerError.exportFailed
        }
    }

    private func makeComposedReactionVideoURL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("composed-reaction-video-\(UUID().uuidString)")
            .appendingPathExtension("mp4")
    }
}

enum ReactionVideoComposerError: LocalizedError {
    case missingVideoTrack
    case cannotCreateCompositionTrack
    case cannotCreateExportSession
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .missingVideoTrack:
            return "합성할 영상 트랙을 찾을 수 없습니다."
        case .cannotCreateCompositionTrack:
            return "영상 합성 트랙을 만들 수 없습니다."
        case .cannotCreateExportSession:
            return "영상 내보내기를 준비할 수 없습니다."
        case .exportFailed:
            return "리액션 영상 생성에 실패했습니다."
        }
    }
}

private struct ReactionVideoSource {
    let frontCameraAsset: AVAsset
    let screenRecordingAsset: AVAsset
    let frontCameraTrack: AVAssetTrack
    let screenRecordingTrack: AVAssetTrack
    let duration: CMTime
}

private struct ReactionVideoComposition {
    let asset: AVMutableComposition
    let frontCameraTrack: AVMutableCompositionTrack
    let screenRecordingTrack: AVMutableCompositionTrack
}
