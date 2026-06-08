import SwiftUI
import UIKit

struct MainEditView: View {
    @State private var selectedTool: MainEditTool?
    @State private var previewFilterPreset: MainEditFilterPreset = .original
    @State private var appliedFilterPreset: MainEditFilterPreset = .original
    @State private var canvasImage: UIImage?
    @State private var isShowingCoverSelection = false

    let framingResult: PhotoFramingResult
    let backButtonAction: () -> Void
    let completeButtonAction: () -> Void
    private let image: UIImage?

    init(
        framingResult: PhotoFramingResult,
        backButtonAction: @escaping () -> Void,
        completeButtonAction: @escaping () -> Void
    ) {
        self.framingResult = framingResult
        self.backButtonAction = backButtonAction
        self.completeButtonAction = completeButtonAction
        let image = UIImage(data: framingResult.source)
        self.image = image
        self._canvasImage = State(initialValue: image)
    }

    var body: some View {
        GeometryReader { proxy in
            let topPanelHeight = topPanelHeight(
                safeAreaInsets: proxy.safeAreaInsets
            )
            let panelHeight = bottomPanelHeight(
                safeAreaInsets: proxy.safeAreaInsets
            )
            let canvasSize = MainEditLayout.canvasSize(
                in: proxy.size,
                safeAreaInsets: proxy.safeAreaInsets,
                topPanelHeight: topPanelHeight,
                bottomPanelHeight: panelHeight
            )

            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack {
                    topPanel
                    
                    Spacer()

                    MainEditCanvas(
                        framingResult: framingResult,
                        image: canvasImage,
                        frameSize: canvasSize
                    )
                    .frame(width: canvasSize.width, height: canvasSize.height)
                    
                    Spacer()

                    bottomPanel
                        .frame(height: panelHeight, alignment: .top)
                        .background(MainEditLayout.bottomPanelBackgroundColor)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .background(Color.black)
        .onChange(of: selectedTool) { _, newValue in
            if newValue == .filter {
                previewFilterPreset = appliedFilterPreset
                updateCanvasImage(applying: appliedFilterPreset)
            } else {
                updateCanvasImage(applying: appliedFilterPreset)
            }
        }
        .onChange(of: previewFilterPreset) { _, newValue in
            if selectedTool == .filter {
                updateCanvasImage(applying: newValue)
            }
        }
        .onChange(of: appliedFilterPreset) { _, newValue in
            if selectedTool != .filter {
                updateCanvasImage(applying: newValue)
            }
        }
        .navigationDestination(isPresented: $isShowingCoverSelection) {
            CoverSelectionView(
                framingResult: framingResult,
                image: image,
                backButtonAction: {
                    isShowingCoverSelection = false
                }
            )
            .navigationBarBackButtonHidden(true)
        }
    }
}

private extension MainEditView {
    @ViewBuilder
    var topPanel: some View {
        if selectedTool != .filter {
            TopBar(
                backButtonAction: backButtonAction,
                nextButtonAction: {
                    isShowingCoverSelection = true
                }
            )
        }
    }

    @ViewBuilder
    var bottomPanel: some View {
        if selectedTool == .filter {
            MainEditFilterPanel(
                previewFilterPreset: $previewFilterPreset,
                thumbnailImage: image,
                cancelAction: cancelFilterPreview,
                confirmAction: applyFilterPreview
            )
        } else {
            EditToolBar(selectedTool: $selectedTool)
        }
    }

    func topPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        selectedTool == .filter
            ? 0
            : MainEditLayout.topBarTotalHeight(safeAreaInsets: safeAreaInsets)
    }

    func bottomPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        if selectedTool == .filter {
            MainEditLayout.filterPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else {
            MainEditLayout.bottomToolBarTotalHeight(safeAreaInsets: safeAreaInsets)
        }
    }

    func cancelFilterPreview() {
        previewFilterPreset = appliedFilterPreset
        updateCanvasImage(applying: appliedFilterPreset)
        selectedTool = nil
    }

    func applyFilterPreview() {
        appliedFilterPreset = previewFilterPreset
        updateCanvasImage(applying: previewFilterPreset)
        selectedTool = nil
    }

    func updateCanvasImage(applying preset: MainEditFilterPreset) {
        guard let image else {
            canvasImage = nil
            return
        }

        canvasImage = MainEditFilterRenderer.shared.image(
            applying: preset,
            to: image
        )
    }
}

#Preview {
    MainEditView(
        framingResult: .mainEditViewPreviewValue,
        backButtonAction: {},
        completeButtonAction: {}
    )
}

private extension PhotoFramingResult {
    static var mainEditViewPreviewValue: PhotoFramingResult {
        var transformState = PhotoFramingTransformState()
        transformState.frameSize = CGSize(width: 297, height: 446)
        transformState.basePhotoSize = CGSize(width: 534, height: 300)
        transformState.minimumScale = 0.45
        transformState.scale = 1
        transformState.offset = .zero
        transformState.sourceAspectRatio = 402 / 226

        return PhotoFramingResult(
            source: Data(),
            backgroundColor: .white,
            transformState: transformState,
            sourcePreviewFrame: nil,
            isLandscapeCapture: true
        )
    }
}
