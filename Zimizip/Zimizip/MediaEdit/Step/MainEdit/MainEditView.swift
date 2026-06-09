import SwiftUI
import UIKit

struct MainEditView: View {
    @State private var selectedTool: MainEditTool?
    @State private var previewFilterPreset: MainEditFilterPreset = .original
    @State private var appliedFilterPreset: MainEditFilterPreset = .original
    @State private var appliedStickerItems: [MainEditStickerItem] = []
    @State private var previewStickerItems: [MainEditStickerItem] = []
    @State private var selectedStickerItemID: MainEditStickerItem.ID?
    @State private var draggingStickerItemID: MainEditStickerItem.ID?
    @State private var draggingStickerStartCenter: CGPoint?
    @State private var scalingStickerItemID: MainEditStickerItem.ID?
    @State private var scalingStickerStartScale: CGFloat?
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
                        frameSize: canvasSize,
                        stickers: canvasStickerItems,
                        selectedStickerID: canvasSelectedStickerID,
                        selectStickerAction: selectStickerItem,
                        dragStickerAction: dragStickerItem,
                        endStickerDragAction: endStickerDrag,
                        scaleStickerAction: scaleStickerItem,
                        endStickerScaleAction: endStickerScale
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
        MainEditEditState(
            filterPreset: appliedFilterPreset,
            stickers: appliedStickerItems
        )
    }

    var canvasStickerItems: [MainEditStickerItem] {
        selectedTool == .sticker ? previewStickerItems : appliedStickerItems
    }

    var canvasSelectedStickerID: MainEditStickerItem.ID? {
        selectedTool == .sticker ? selectedStickerItemID : nil
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
        } else if tool == .sticker {
            beginStickerPreview()
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
            MainEditEditState(
                filterPreset: previewFilterPreset,
                stickers: appliedStickerItems
            )
        )
        selectedTool = nil
    }

    func beginStickerPreview() {
        previewStickerItems = appliedStickerItems
        selectedStickerItemID = nil
        endStickerDrag()
        endStickerScale()
    }

    func selectStickerSource(_ source: MainEditStickerSource) {
        let sticker = MainEditStickerItem(
            source: source,
            zIndex: nextStickerZIndex
        )

        previewStickerItems.append(sticker)
        selectedStickerItemID = sticker.id
    }

    func selectStickerItem(_ id: MainEditStickerItem.ID) {
        guard selectedTool == .sticker else {
            return
        }

        selectedStickerItemID = id
    }

    func dragStickerItem(
        _ id: MainEditStickerItem.ID,
        translation: CGSize,
        frameSize: CGSize
    ) {
        guard frameSize.width > 0,
              frameSize.height > 0,
              selectedTool == .sticker,
              let index = previewStickerItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        if draggingStickerItemID != id {
            draggingStickerItemID = id
            draggingStickerStartCenter = previewStickerItems[index].normalizedCenter
        }

        guard let draggingStickerStartCenter else {
            return
        }

        let proposedCenter = CGPoint(
            x: draggingStickerStartCenter.x + translation.width / frameSize.width,
            y: draggingStickerStartCenter.y + translation.height / frameSize.height
        )

        previewStickerItems[index].normalizedCenter = clampedStickerCenter(proposedCenter)
    }

    func endStickerDrag() {
        draggingStickerItemID = nil
        draggingStickerStartCenter = nil
    }

    func scaleStickerItem(
        _ id: MainEditStickerItem.ID,
        magnification: CGFloat,
        frameSize: CGSize
    ) {
        guard frameSize.width > 0,
              frameSize.height > 0,
              selectedTool == .sticker,
              let index = previewStickerItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        if scalingStickerItemID != id {
            scalingStickerItemID = id
            scalingStickerStartScale = previewStickerItems[index].scale
        }

        guard let scalingStickerStartScale else {
            return
        }

        previewStickerItems[index].scale = clampedStickerScale(
            scalingStickerStartScale * magnification
        )
        previewStickerItems[index].normalizedCenter = clampedStickerCenter(
            previewStickerItems[index].normalizedCenter
        )
    }

    func endStickerScale() {
        scalingStickerItemID = nil
        scalingStickerStartScale = nil
    }

    func cancelStickerPanel() {
        previewStickerItems = appliedStickerItems
        selectedStickerItemID = nil
        endStickerDrag()
        endStickerScale()
        selectedTool = nil
    }

    func confirmStickerPanel() {
        commitEditState(
            MainEditEditState(
                filterPreset: appliedFilterPreset,
                stickers: previewStickerItems
            )
        )
        selectedStickerItemID = nil
        endStickerDrag()
        endStickerScale()
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
        appliedStickerItems = state.stickers
        previewStickerItems = state.stickers

        if let selectedStickerItemID,
           !state.stickers.contains(where: { $0.id == selectedStickerItemID }) {
            self.selectedStickerItemID = nil
        }

        endStickerDrag()
        endStickerScale()
    }

    func showCoverSelection() {
        mainEditResult = makeMainEditResult()
    }

    func makeMainEditResult() -> MainEditResult {
        MainEditResult(
            framingResult: framingResult,
            appliedFilterPreset: appliedFilterPreset,
            image: renderedCompositeImage()
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

    func renderedCompositeImage() -> UIImage? {
        guard let filteredImage = renderedImage(applying: appliedFilterPreset) else {
            return nil
        }

        return MainEditCompositeRenderer.shared.image(
            framingResult: framingResult,
            image: filteredImage,
            stickers: appliedStickerItems
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

    var nextStickerZIndex: Int {
        (previewStickerItems.map(\.zIndex).max() ?? -1) + 1
    }

    func clampedStickerCenter(_ center: CGPoint) -> CGPoint {
        CGPoint(
            x: clampedNormalizedValue(center.x),
            y: clampedNormalizedValue(center.y)
        )
    }

    func clampedNormalizedValue(_ value: CGFloat) -> CGFloat {
        min(max(value, 0), 1)
    }

    func clampedStickerScale(_ scale: CGFloat) -> CGFloat {
        min(
            max(scale, MainEditLayout.stickerMinimumScale),
            MainEditLayout.stickerMaximumScale
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
