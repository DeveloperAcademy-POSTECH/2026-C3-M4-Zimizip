import SwiftUI
import UIKit

struct MainEditView: View {
    @State private var selectedTool: MainEditTool?
    @State private var previewFilterPreset: MainEditFilterPreset = .original
    @State private var appliedFilterPreset: MainEditFilterPreset = .original
    @State private var canvasImage: UIImage?
    @State private var filterThumbnailImages: [MainEditFilterPreset: UIImage] = [:]
    @State private var undoStack: [MainEditEditState] = []
    @State private var redoStack: [MainEditEditState] = []
    @State private var mainEditResult: MainEditResult?

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

                historyControls
                    .padding(.leading, MainEditLayout.historyControlLeadingPadding)
                    .padding(
                        .bottom,
                        panelHeight + MainEditLayout.historyControlBottomSpacing
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )
            }
        }
        .background(Color.black)
        .onChange(of: selectedTool) { _, newValue in
            handleSelectedToolChange(newValue)
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
        .navigationDestination(isPresented: isShowingCoverSelection) {
            if let mainEditResult {
                CoverSelectionView(
                    mainEditResult: mainEditResult,
                    backButtonAction: {
                        self.mainEditResult = nil
                    }
                )
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

private extension MainEditView {
    var isShowingCoverSelection: Binding<Bool> {
        Binding {
            mainEditResult != nil
        } set: { isPresented in
            if !isPresented {
                mainEditResult = nil
            }
        }
    }

    @ViewBuilder
    var topPanel: some View {
        if !isBottomEditingPanelPresented {
            TopBar(
                backButtonAction: backButtonAction,
                nextButtonAction: {
                    showCoverSelection()
                }
            )
        }
    }

    @ViewBuilder
    var bottomPanel: some View {
        if selectedTool == .filter {
            MainEditFilterPanel(
                previewFilterPreset: $previewFilterPreset,
                thumbnailImages: filterThumbnailImages,
                cancelAction: cancelFilterPreview,
                confirmAction: applyFilterPreview
            )
        } else if selectedTool == .sticker {
            MainEditStickerPanel(
                selectAction: selectStickerSource,
                cancelAction: cancelStickerPanel,
                confirmAction: confirmStickerPanel
            )
        } else {
            EditToolBar(selectedTool: $selectedTool)
        }
    }

    @ViewBuilder
    var historyControls: some View {
        let canUndo = !undoStack.isEmpty
        let canRedo = !redoStack.isEmpty

        if selectedTool == nil && (canUndo || canRedo) {
            MainEditHistoryControls(
                canUndo: canUndo,
                canRedo: canRedo,
                undoAction: undoEdit,
                redoAction: redoEdit
            )
        }
    }

    var currentEditState: MainEditEditState {
        MainEditEditState(filterPreset: appliedFilterPreset)
    }

    var isBottomEditingPanelPresented: Bool {
        selectedTool == .filter || selectedTool == .sticker
    }

    func topPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        isBottomEditingPanelPresented
            ? 0
            : MainEditLayout.topBarTotalHeight(safeAreaInsets: safeAreaInsets)
    }

    func bottomPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        if selectedTool == .filter {
            MainEditLayout.filterPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else if selectedTool == .sticker {
            MainEditLayout.stickerPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else {
            MainEditLayout.bottomToolBarTotalHeight(safeAreaInsets: safeAreaInsets)
        }
    }

    func handleSelectedToolChange(_ tool: MainEditTool?) {
        if tool == .filter {
            beginFilterPreview()
        } else {
            updateCanvasImage(applying: appliedFilterPreset)
        }
    }

    func beginFilterPreview() {
        previewFilterPreset = appliedFilterPreset
        prepareFilterThumbnailImagesIfNeeded()
        updateCanvasImage(applying: appliedFilterPreset)
    }

    func cancelFilterPreview() {
        selectedTool = nil
        previewFilterPreset = appliedFilterPreset
    }

    func applyFilterPreview() {
        commitEditState(
            MainEditEditState(filterPreset: previewFilterPreset)
        )
        selectedTool = nil
    }

    func selectStickerSource(_ source: MainEditStickerSource) {
        // Sticker placement is connected in the functionality branch.
    }

    func cancelStickerPanel() {
        selectedTool = nil
    }

    func confirmStickerPanel() {
        selectedTool = nil
    }

    func commitEditState(_ newState: MainEditEditState) {
        let previousState = currentEditState

        guard newState != previousState else {
            return
        }

        undoStack.append(previousState)
        redoStack.removeAll()
        applyEditState(newState)
    }

    func undoEdit() {
        guard let previousState = undoStack.popLast() else {
            return
        }

        redoStack.append(currentEditState)
        applyEditState(previousState)
    }

    func redoEdit() {
        guard let nextState = redoStack.popLast() else {
            return
        }

        undoStack.append(currentEditState)
        applyEditState(nextState)
    }

    func applyEditState(_ state: MainEditEditState) {
        previewFilterPreset = state.filterPreset
        appliedFilterPreset = state.filterPreset
    }

    func showCoverSelection() {
        mainEditResult = makeMainEditResult()
    }

    func makeMainEditResult() -> MainEditResult {
        MainEditResult(
            framingResult: framingResult,
            appliedFilterPreset: appliedFilterPreset,
            image: renderedImage(applying: appliedFilterPreset)
        )
    }

    func updateCanvasImage(applying preset: MainEditFilterPreset) {
        canvasImage = renderedImage(applying: preset)
    }

    func renderedImage(applying preset: MainEditFilterPreset) -> UIImage? {
        guard let image else {
            return nil
        }

        return MainEditFilterRenderer.shared.image(
            applying: preset,
            to: image
        )
    }

    func prepareFilterThumbnailImagesIfNeeded() {
        guard filterThumbnailImages.isEmpty,
              let image else {
            return
        }

        filterThumbnailImages = Dictionary(
            uniqueKeysWithValues: MainEditFilterPreset.allCases.map { preset in
                (
                    preset,
                    MainEditFilterRenderer.shared.image(
                        applying: preset,
                        to: image
                    )
                )
            }
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
