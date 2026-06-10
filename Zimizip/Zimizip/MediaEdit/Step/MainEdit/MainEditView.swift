import SwiftUI
import UIKit

struct MainEditView: View {
    @State private var selectedTool: MainEditTool?
    @State private var previewFilterPreset: MainEditFilterPreset = .original
    @State private var appliedFilterPreset: MainEditFilterPreset = .original
    @State private var selectedAdjustmentOption: MainEditAdjustmentOption?
    @State private var previewAdjustmentValues: [MainEditAdjustmentOption: Int] = [:]
    @State private var appliedAdjustmentValues: [MainEditAdjustmentOption: Int] = [:]
    @State private var appliedStickerItems: [MainEditStickerItem] = []
    @State private var previewStickerItems: [MainEditStickerItem] = []
    @State private var selectedStickerItemID: MainEditStickerItem.ID?
    @State private var appliedTextItems: [MainEditTextItem] = []
    @State private var previewTextItems: [MainEditTextItem] = []
    @State private var selectedTextItemID: MainEditTextItem.ID?
    @State private var selectedTextFont: MainEditTextFont = .default
    @State private var selectedTextColor: MainEditTextColor = .white
    @State private var draggingTextItemID: MainEditTextItem.ID?
    @State private var draggingTextStartCenter: CGPoint?
    @State private var scalingTextItemID: MainEditTextItem.ID?
    @State private var scalingTextStartScale: CGFloat?
    @State private var draggingStickerItemID: MainEditStickerItem.ID?
    @State private var draggingStickerStartCenter: CGPoint?
    @State private var scalingStickerItemID: MainEditStickerItem.ID?
    @State private var scalingStickerStartScale: CGFloat?
    @State private var canvasImage: UIImage?
    @State private var filterThumbnailImages: [MainEditFilterPreset: UIImage] = [:]
    @State private var undoStack: [MainEditEditState] = []
    @State private var redoStack: [MainEditEditState] = []
    @State private var isTextInputPresented = false
    @State private var textInputDraft = ""
    @State private var textInputStyleRuns: [MainEditTextStyleRun] = []
    @State private var textInputSelectedRange = NSRange(location: 0, length: 0)
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
                    Spacer()

                    MainEditCanvas(
                        framingResult: framingResult,
                        image: canvasImage,
                        frameSize: canvasSize,
                        texts: canvasTextItems,
                        selectedTextID: canvasSelectedTextID,
                        selectTextAction: selectTextItem,
                        textTapAction: selectTextItemForInput,
                        deleteTextAction: deleteTextItem,
                        duplicateTextAction: duplicateTextItem,
                        dragTextAction: dragTextItem,
                        endTextDragAction: endTextDrag,
                        scaleTextAction: scaleTextItem,
                        endTextScaleAction: endTextScale,
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
                        historyControlBottomPadding(panelHeight: panelHeight)
                    )
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomLeading
                    )

                topPanel
                    .frame(height: MainEditLayout.topBarContentHeight, alignment: .top)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .zIndex(1)
                if isTextInputPresented {
                    MainEditTextInputOverlay(
                        text: $textInputDraft,
                        styleRuns: $textInputStyleRuns,
                        selectedRange: $textInputSelectedRange,
                        font: selectedTextFont,
                        color: selectedTextColor,
                        cancelAction: cancelTextInputOverlay,
                        confirmAction: confirmTextInputOverlay
                    )
                }
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
        .onChange(of: previewAdjustmentValues) { _, newValue in
            if selectedTool == .adjustment {
                updateCanvasImage(
                    applying: appliedFilterPreset,
                    adjustmentValues: newValue
                )
            }
        }
        .onChange(of: appliedAdjustmentValues) { _, newValue in
            if selectedTool != .adjustment {
                updateCanvasImage(
                    applying: appliedFilterPreset,
                    adjustmentValues: newValue
                )
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
        } else if selectedTool == .adjustment {
            MainEditAdjustmentPanel(
                selectedOption: $selectedAdjustmentOption,
                adjustmentValues: $previewAdjustmentValues,
                cancelAction: cancelAdjustmentPanel,
                confirmAction: confirmAdjustmentPanel
            )
        } else if selectedTool == .sticker {
            MainEditStickerPanel(
                selectAction: selectStickerSource,
                cancelAction: cancelStickerPanel,
                confirmAction: confirmStickerPanel
            )
        } else if selectedTool == .text {
            MainEditTextPanel(
                selectedFont: $selectedTextFont,
                selectedColor: $selectedTextColor,
                selectFontAction: selectTextFont,
                selectColorAction: selectTextColor,
                cancelAction: cancelTextPanel,
                confirmAction: confirmTextPanel
            )
        } else {
            EditToolBar(selectedTool: $selectedTool)
        }
    }

    @ViewBuilder
    var historyControls: some View {
        if isHistoryControlsPresented {
            MainEditHistoryControls(
                canUndo: canUndoCurrentEdit,
                canRedo: canRedoCurrentEdit,
                undoAction: undoCurrentEdit,
                redoAction: redoEdit
            )
        }
    }

    var currentEditState: MainEditEditState {
        MainEditEditState(
            filterPreset: appliedFilterPreset,
            adjustmentValues: sanitizedAdjustmentValues(appliedAdjustmentValues),
            texts: appliedTextItems,
            stickers: appliedStickerItems
        )
    }

    var canvasStickerItems: [MainEditStickerItem] {
        selectedTool == .sticker ? previewStickerItems : appliedStickerItems
    }

    var canvasTextItems: [MainEditTextItem] {
        selectedTool == .text ? previewTextItems : appliedTextItems
    }

    var canvasSelectedStickerID: MainEditStickerItem.ID? {
        selectedTool == .sticker ? selectedStickerItemID : nil
    }

    var canvasSelectedTextID: MainEditTextItem.ID? {
        selectedTool == .text ? selectedTextItemID : nil
    }

    var isBottomEditingPanelPresented: Bool {
        selectedTool == .filter ||
            selectedTool == .adjustment ||
            selectedTool == .sticker ||
            selectedTool == .text
    }

    var hasPendingToolPreviewChanges: Bool {
        if selectedTool == .filter {
            return previewFilterPreset != appliedFilterPreset
        } else if selectedTool == .adjustment {
            return sanitizedAdjustmentValues(previewAdjustmentValues) !=
                sanitizedAdjustmentValues(appliedAdjustmentValues)
        } else if selectedTool == .sticker {
            return previewStickerItems != appliedStickerItems
        } else if selectedTool == .text {
            return previewTextItems != appliedTextItems
        }

        return false
    }

    var canUndoCurrentEdit: Bool {
        hasPendingToolPreviewChanges || !undoStack.isEmpty
    }

    var canRedoCurrentEdit: Bool {
        !hasPendingToolPreviewChanges && !redoStack.isEmpty
    }

    var isHistoryControlsPresented: Bool {
        canUndoCurrentEdit || canRedoCurrentEdit
    }

    func historyControlBottomPadding(panelHeight: CGFloat) -> CGFloat {
        guard isBottomEditingPanelPresented else {
            return panelHeight + MainEditLayout.historyControlBottomSpacing
        }

        return max(
            panelHeight -
                MainEditLayout.historyControlIconSize -
                MainEditLayout.historyControlEditingPanelBottomSpacing,
            0
        )
    }

    func topPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        isBottomEditingPanelPresented
            ? 0
            : MainEditLayout.topBarTotalHeight(safeAreaInsets: safeAreaInsets)
    }

    func bottomPanelHeight(safeAreaInsets: EdgeInsets) -> CGFloat {
        if selectedTool == .filter {
            MainEditLayout.filterPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else if selectedTool == .adjustment {
            MainEditLayout.adjustmentPanelTotalHeight(
                safeAreaInsets: safeAreaInsets,
                isSliderPresented: selectedAdjustmentOption != nil
            )
        } else if selectedTool == .sticker {
            MainEditLayout.stickerPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else if selectedTool == .text {
            MainEditLayout.textPanelTotalHeight(safeAreaInsets: safeAreaInsets)
        } else {
            MainEditLayout.bottomToolBarTotalHeight(safeAreaInsets: safeAreaInsets)
        }
    }

    func handleSelectedToolChange(_ tool: MainEditTool?) {
        if tool == .filter {
            beginFilterPreview()
        } else if tool == .adjustment {
            beginAdjustmentPanel()
        } else if tool == .sticker {
            beginStickerPreview()
        } else if tool == .text {
            beginTextPanel()
        } else {
            updateCanvasImage(
                applying: appliedFilterPreset,
                adjustmentValues: appliedAdjustmentValues
            )
        }
    }

    func beginFilterPreview() {
        previewFilterPreset = appliedFilterPreset
        prepareFilterThumbnailImagesIfNeeded()
        updateCanvasImage(
            applying: appliedFilterPreset,
            adjustmentValues: appliedAdjustmentValues
        )
    }

    func cancelFilterPreview() {
        selectedTool = nil
        previewFilterPreset = appliedFilterPreset
    }

    func applyFilterPreview() {
        commitEditState(
            MainEditEditState(
                filterPreset: previewFilterPreset,
                adjustmentValues: sanitizedAdjustmentValues(appliedAdjustmentValues),
                texts: appliedTextItems,
                stickers: appliedStickerItems
            )
        )
        selectedTool = nil
    }

    func beginAdjustmentPanel() {
        selectedAdjustmentOption = nil
        previewAdjustmentValues = appliedAdjustmentValues
        updateCanvasImage(
            applying: appliedFilterPreset,
            adjustmentValues: appliedAdjustmentValues
        )
    }

    func cancelAdjustmentPanel() {
        previewAdjustmentValues = appliedAdjustmentValues
        selectedAdjustmentOption = nil
        selectedTool = nil
    }

    func confirmAdjustmentPanel() {
        commitEditState(
            MainEditEditState(
                filterPreset: appliedFilterPreset,
                adjustmentValues: sanitizedAdjustmentValues(previewAdjustmentValues),
                texts: appliedTextItems,
                stickers: appliedStickerItems
            )
        )
        selectedAdjustmentOption = nil
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
                adjustmentValues: sanitizedAdjustmentValues(appliedAdjustmentValues),
                texts: appliedTextItems,
                stickers: previewStickerItems
            )
        )
        selectedStickerItemID = nil
        endStickerDrag()
        endStickerScale()
        selectedTool = nil
    }

    func beginTextPanel() {
        previewTextItems = appliedTextItems
        selectedTextItemID = previewTextItems.last?.id
        selectedTextFont = selectedTextItemID.flatMap(textFont(for:)) ?? .default
        selectedTextColor = selectedTextItemID.flatMap(textColor(for:)) ?? .white
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
        endTextDrag()
        endTextScale()
        updateCanvasImage(
            applying: appliedFilterPreset,
            adjustmentValues: appliedAdjustmentValues
        )
    }

    func cancelTextPanel() {
        previewTextItems = appliedTextItems
        selectedTextItemID = nil
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
        endTextDrag()
        endTextScale()
        selectedTool = nil
    }

    func confirmTextPanel() {
        commitEditState(
            MainEditEditState(
                filterPreset: appliedFilterPreset,
                adjustmentValues: sanitizedAdjustmentValues(appliedAdjustmentValues),
                texts: previewTextItems,
                stickers: appliedStickerItems
            )
        )
        selectedTextItemID = nil
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
        endTextDrag()
        endTextScale()
        selectedTool = nil
    }

    func selectTextFont(_ font: MainEditTextFont) {
        selectedTextFont = font

        guard selectedTool == .text else {
            return
        }

        if let selectedTextItemID,
           previewTextItems.contains(where: { $0.id == selectedTextItemID }) {
            if isTextInputPresented {
                textInputStyleRuns = fontAppliedStyleRuns(
                    textInputStyleRuns,
                    textLength: textInputDraft.count,
                    font: font,
                    selectedRange: textInputSelectedRange
                )
            } else {
                applyTextFont(font, to: selectedTextItemID)
            }
            return
        }

        let textItem = MainEditTextItem(
            font: font,
            color: selectedTextColor,
            zIndex: nextTextZIndex
        )

        previewTextItems.append(textItem)
        selectedTextItemID = textItem.id
    }

    func applyTextFont(_ font: MainEditTextFont, to id: MainEditTextItem.ID) {
        guard let index = previewTextItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        previewTextItems[index].styleRuns = fontAppliedStyleRuns(
            previewTextItems[index].styleRuns,
            textLength: previewTextItems[index].text.count,
            font: font,
            selectedRange: NSRange(
                location: 0,
                length: previewTextItems[index].text.count
            )
        )
    }

    func selectTextColor(_ color: MainEditTextColor) {
        selectedTextColor = color

        guard selectedTool == .text,
              let selectedTextItemID,
              previewTextItems.contains(where: { $0.id == selectedTextItemID }) else {
            return
        }

        if isTextInputPresented {
            textInputStyleRuns = colorAppliedStyleRuns(
                textInputStyleRuns,
                textLength: textInputDraft.count,
                color: color,
                selectedRange: textInputSelectedRange
            )
        } else {
            applyTextColor(color, to: selectedTextItemID)
        }
    }

    func applyTextColor(_ color: MainEditTextColor, to id: MainEditTextItem.ID) {
        guard let index = previewTextItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        previewTextItems[index].styleRuns = colorAppliedStyleRuns(
            previewTextItems[index].styleRuns,
            textLength: previewTextItems[index].text.count,
            color: color,
            selectedRange: NSRange(
                location: 0,
                length: previewTextItems[index].text.count
            )
        )
    }

    func selectTextItem(_ id: MainEditTextItem.ID) {
        guard selectedTool == .text else {
            return
        }

        selectedTextItemID = id
        selectedTextFont = textFont(for: id) ?? selectedTextFont
        selectedTextColor = textColor(for: id) ?? selectedTextColor
    }

    func selectTextItemForInput(_ id: MainEditTextItem.ID) {
        guard selectedTool == .text else {
            return
        }

        selectTextItem(id)
        let currentText = textValue(for: id) ?? ""
        textInputDraft = currentText == MainEditLayout.textPreviewPlaceholder
            ? ""
            : currentText
        textInputStyleRuns = styleRuns(for: id)
        textInputSelectedRange = NSRange(location: textInputDraft.count, length: 0)
        isTextInputPresented = true
    }

    func deleteTextItem(_ id: MainEditTextItem.ID) {
        guard selectedTool == .text else {
            return
        }

        previewTextItems.removeAll { $0.id == id }

        if selectedTextItemID == id {
            selectedTextItemID = previewTextItems.last?.id
        }

        endTextDrag()
        endTextScale()
    }

    func duplicateTextItem(_ id: MainEditTextItem.ID) {
        guard selectedTool == .text,
              let sourceText = previewTextItems.first(where: { $0.id == id }) else {
            return
        }

        let duplicatedText = MainEditTextItem(
            text: sourceText.text,
            styleRuns: sourceText.styleRuns,
            normalizedCenter: clampedTextCenter(
                CGPoint(
                    x: sourceText.normalizedCenter.x + MainEditLayout.textDuplicateOffsetRatio,
                    y: sourceText.normalizedCenter.y + MainEditLayout.textDuplicateOffsetRatio
                )
            ),
            scale: sourceText.scale,
            zIndex: nextTextZIndex
        )

        previewTextItems.append(duplicatedText)
        selectedTextItemID = duplicatedText.id
        selectedTextFont = textFont(for: duplicatedText.id) ?? selectedTextFont
        selectedTextColor = textColor(for: duplicatedText.id) ?? selectedTextColor
    }

    func dragTextItem(
        _ id: MainEditTextItem.ID,
        translation: CGSize,
        frameSize: CGSize
    ) {
        guard frameSize.width > 0,
              frameSize.height > 0,
              selectedTool == .text,
              let index = previewTextItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        if draggingTextItemID != id {
            draggingTextItemID = id
            draggingTextStartCenter = previewTextItems[index].normalizedCenter
        }

        guard let draggingTextStartCenter else {
            return
        }

        let proposedCenter = CGPoint(
            x: draggingTextStartCenter.x + translation.width / frameSize.width,
            y: draggingTextStartCenter.y + translation.height / frameSize.height
        )

        previewTextItems[index].normalizedCenter = clampedTextCenter(proposedCenter)
    }

    func endTextDrag() {
        draggingTextItemID = nil
        draggingTextStartCenter = nil
    }

    func scaleTextItem(
        _ id: MainEditTextItem.ID,
        magnification: CGFloat,
        frameSize: CGSize
    ) {
        guard frameSize.width > 0,
              frameSize.height > 0,
              selectedTool == .text,
              let index = previewTextItems.firstIndex(where: { $0.id == id }) else {
            return
        }

        if scalingTextItemID != id {
            scalingTextItemID = id
            scalingTextStartScale = previewTextItems[index].scale
        }

        guard let scalingTextStartScale else {
            return
        }

        previewTextItems[index].scale = clampedTextScale(
            scalingTextStartScale * magnification
        )
        previewTextItems[index].normalizedCenter = clampedTextCenter(
            previewTextItems[index].normalizedCenter
        )
    }

    func endTextScale() {
        scalingTextItemID = nil
        scalingTextStartScale = nil
    }

    func cancelTextInputOverlay() {
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
    }

    func confirmTextInputOverlay() {
        guard selectedTool == .text,
              let selectedTextItemID,
              let index = previewTextItems.firstIndex(where: { $0.id == selectedTextItemID }) else {
            cancelTextInputOverlay()
            return
        }

        let resolvedText = textInputDraft.isEmpty
            ? MainEditLayout.textPreviewPlaceholder
            : textInputDraft
        previewTextItems[index].text = resolvedText
        previewTextItems[index].styleRuns = normalizedStyleRuns(
            textInputStyleRuns,
            textLength: resolvedText.count
        )
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
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

    func undoCurrentEdit() {
        if hasPendingToolPreviewChanges {
            discardCurrentToolPreviewChanges()
        } else {
            undoEdit()
        }
    }

    func discardCurrentToolPreviewChanges() {
        if selectedTool == .filter {
            previewFilterPreset = appliedFilterPreset
            updateCanvasImage(
                applying: appliedFilterPreset,
                adjustmentValues: appliedAdjustmentValues
            )
        } else if selectedTool == .adjustment {
            previewAdjustmentValues = appliedAdjustmentValues
            updateCanvasImage(
                applying: appliedFilterPreset,
                adjustmentValues: appliedAdjustmentValues
            )
        } else if selectedTool == .sticker {
            previewStickerItems = appliedStickerItems
            selectedStickerItemID = nil
            endStickerDrag()
            endStickerScale()
        } else if selectedTool == .text {
            previewTextItems = appliedTextItems
            selectedTextItemID = previewTextItems.last?.id
            isTextInputPresented = false
            textInputDraft = ""
            textInputStyleRuns = []
            textInputSelectedRange = NSRange(location: 0, length: 0)
            endTextDrag()
            endTextScale()
        }
    }

    func applyEditState(_ state: MainEditEditState) {
        previewFilterPreset = state.filterPreset
        appliedFilterPreset = state.filterPreset
        previewAdjustmentValues = state.adjustmentValues
        appliedAdjustmentValues = state.adjustmentValues
        appliedTextItems = state.texts
        previewTextItems = state.texts
        appliedStickerItems = state.stickers
        previewStickerItems = state.stickers

        if let selectedTextItemID,
           !state.texts.contains(where: { $0.id == selectedTextItemID }) {
            self.selectedTextItemID = nil
        }

        if let selectedStickerItemID,
           !state.stickers.contains(where: { $0.id == selectedStickerItemID }) {
            self.selectedStickerItemID = nil
        }

        selectedTextFont = selectedTextItemID.flatMap(textFont(for:)) ?? selectedTextFont
        selectedTextColor = selectedTextItemID.flatMap(textColor(for:)) ?? selectedTextColor
        isTextInputPresented = false
        textInputDraft = ""
        textInputStyleRuns = []
        textInputSelectedRange = NSRange(location: 0, length: 0)
        endTextDrag()
        endTextScale()
        endStickerDrag()
        endStickerScale()
        updateCanvasImage(
            applying: state.filterPreset,
            adjustmentValues: state.adjustmentValues
        )
    }

    func showCoverSelection() {
        mainEditResult = makeMainEditResult()
    }

    func makeMainEditResult() -> MainEditResult {
        MainEditResult(
            framingResult: framingResult,
            appliedFilterPreset: appliedFilterPreset,
            appliedAdjustmentValues: sanitizedAdjustmentValues(appliedAdjustmentValues),
            image: renderedCompositeImage()
        )
    }

    func updateCanvasImage(applying preset: MainEditFilterPreset) {
        updateCanvasImage(
            applying: preset,
            adjustmentValues: appliedAdjustmentValues
        )
    }

    func updateCanvasImage(
        applying preset: MainEditFilterPreset,
        adjustmentValues: [MainEditAdjustmentOption: Int]
    ) {
        canvasImage = renderedCanvasImage(
            applying: preset,
            adjustmentValues: adjustmentValues
        )
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

    func renderedCanvasImage(
        applying preset: MainEditFilterPreset,
        adjustmentValues: [MainEditAdjustmentOption: Int]
    ) -> UIImage? {
        guard let filteredImage = renderedImage(applying: preset) else {
            return nil
        }

        return MainEditAdjustmentRenderer.shared.image(
            applying: adjustmentValues,
            to: filteredImage
        )
    }

    func renderedCompositeImage() -> UIImage? {
        guard let renderedImage = renderedCanvasImage(
            applying: appliedFilterPreset,
            adjustmentValues: appliedAdjustmentValues
        ) else {
            return nil
        }

        return MainEditCompositeRenderer.shared.image(
            framingResult: framingResult,
            image: renderedImage,
            texts: appliedTextItems,
            stickers: appliedStickerItems
        )
    }

    func sanitizedAdjustmentValues(
        _ values: [MainEditAdjustmentOption: Int]
    ) -> [MainEditAdjustmentOption: Int] {
        Dictionary(
            uniqueKeysWithValues: values.compactMap { option, value in
                let clampedValue = min(max(value, -100), 100)

                guard clampedValue != 0 else {
                    return nil
                }

                return (option, clampedValue)
            }
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

    var nextTextZIndex: Int {
        (previewTextItems.map(\.zIndex).max() ?? -1) + 1
    }

    func textFont(for id: MainEditTextItem.ID) -> MainEditTextFont? {
        previewTextItems
            .first(where: { $0.id == id })?
            .styleRuns
            .first?
            .font
    }

    func textColor(for id: MainEditTextItem.ID) -> MainEditTextColor? {
        previewTextItems
            .first(where: { $0.id == id })?
            .styleRuns
            .first?
            .color
    }

    func textValue(for id: MainEditTextItem.ID) -> String? {
        previewTextItems
            .first(where: { $0.id == id })?
            .text
    }

    func styleRuns(for id: MainEditTextItem.ID) -> [MainEditTextStyleRun] {
        previewTextItems
            .first(where: { $0.id == id })?
            .styleRuns ?? []
    }

    func normalizedStyleRuns(
        _ styleRuns: [MainEditTextStyleRun],
        textLength: Int
    ) -> [MainEditTextStyleRun] {
        guard textLength > 0 else {
            return [
                MainEditTextStyleRun(
                    start: 0,
                    length: textLength,
                    font: selectedTextFont,
                    color: selectedTextColor
                )
            ]
        }

        let clampedRuns = styleRuns
            .sorted { $0.start < $1.start }
            .compactMap { styleRun -> MainEditTextStyleRun? in
                let range = clampedNSRange(
                    NSRange(location: styleRun.start, length: styleRun.length),
                    textLength: textLength
                )

                guard range.length > 0 else {
                    return nil
                }

                return MainEditTextStyleRun(
                    start: range.location,
                    length: range.length,
                    font: styleRun.font,
                    color: styleRun.color
                )
            }

        guard !clampedRuns.isEmpty else {
            return [
                MainEditTextStyleRun(
                    start: 0,
                    length: textLength,
                    font: selectedTextFont,
                    color: selectedTextColor
                )
            ]
        }

        var filledRuns: [MainEditTextStyleRun] = []
        var cursor = 0

        clampedRuns.forEach { styleRun in
            if styleRun.start > cursor {
                filledRuns.append(
                    MainEditTextStyleRun(
                        start: cursor,
                        length: styleRun.start - cursor,
                        font: selectedTextFont,
                        color: selectedTextColor
                    )
                )
            }

            filledRuns.append(styleRun)
            cursor = max(cursor, styleRun.start + styleRun.length)
        }

        if cursor < textLength {
            filledRuns.append(
                MainEditTextStyleRun(
                    start: cursor,
                    length: textLength - cursor,
                    font: selectedTextFont,
                    color: selectedTextColor
                )
            )
        }

        return mergedAdjacentStyleRuns(filledRuns)
    }

    func fontAppliedStyleRuns(
        _ styleRuns: [MainEditTextStyleRun],
        textLength: Int,
        font: MainEditTextFont,
        selectedRange: NSRange
    ) -> [MainEditTextStyleRun] {
        styleRunsApplying(
            styleRuns,
            textLength: textLength,
            selectedRange: selectedRange
        ) { styleRun in
            var updatedRun = styleRun
            updatedRun.font = font
            return updatedRun
        }
    }

    func colorAppliedStyleRuns(
        _ styleRuns: [MainEditTextStyleRun],
        textLength: Int,
        color: MainEditTextColor,
        selectedRange: NSRange
    ) -> [MainEditTextStyleRun] {
        styleRunsApplying(
            styleRuns,
            textLength: textLength,
            selectedRange: selectedRange
        ) { styleRun in
            var updatedRun = styleRun
            updatedRun.color = color
            return updatedRun
        }
    }

    func styleRunsApplying(
        _ styleRuns: [MainEditTextStyleRun],
        textLength: Int,
        selectedRange: NSRange,
        transform: (MainEditTextStyleRun) -> MainEditTextStyleRun
    ) -> [MainEditTextStyleRun] {
        let normalizedRuns = normalizedStyleRuns(styleRuns, textLength: textLength)

        guard textLength > 0 else {
            return normalizedRuns
        }

        let range = clampedNSRange(selectedRange, textLength: textLength)
        guard range.length > 0 else {
            return normalizedRuns
        }

        let targetRange = range
        let targetStart = targetRange.location
        let targetEnd = targetRange.location + targetRange.length
        var updatedRuns: [MainEditTextStyleRun] = []

        normalizedRuns.forEach { styleRun in
            let runStart = styleRun.start
            let runEnd = styleRun.start + styleRun.length

            guard runEnd > targetStart,
                  runStart < targetEnd else {
                updatedRuns.append(styleRun)
                return
            }

            if runStart < targetStart {
                updatedRuns.append(
                    MainEditTextStyleRun(
                        start: runStart,
                        length: targetStart - runStart,
                        font: styleRun.font,
                        color: styleRun.color
                    )
                )
            }

            let overlapStart = max(runStart, targetStart)
            let overlapEnd = min(runEnd, targetEnd)
            var transformedRun = styleRun
            transformedRun.start = overlapStart
            transformedRun.length = overlapEnd - overlapStart
            updatedRuns.append(transform(transformedRun))

            if runEnd > targetEnd {
                updatedRuns.append(
                    MainEditTextStyleRun(
                        start: targetEnd,
                        length: runEnd - targetEnd,
                        font: styleRun.font,
                        color: styleRun.color
                    )
                )
            }
        }

        return mergedAdjacentStyleRuns(updatedRuns)
    }

    func mergedAdjacentStyleRuns(
        _ styleRuns: [MainEditTextStyleRun]
    ) -> [MainEditTextStyleRun] {
        let sortedRuns = styleRuns
            .filter { $0.length > 0 }
            .sorted { $0.start < $1.start }

        return sortedRuns.reduce(into: []) { mergedRuns, styleRun in
            guard var lastRun = mergedRuns.last,
                  lastRun.start + lastRun.length == styleRun.start,
                  lastRun.font == styleRun.font,
                  lastRun.color == styleRun.color else {
                mergedRuns.append(styleRun)
                return
            }

            lastRun.length += styleRun.length
            mergedRuns[mergedRuns.count - 1] = lastRun
        }
    }

    func clampedNSRange(_ range: NSRange, textLength: Int) -> NSRange {
        let location = min(max(range.location, 0), textLength)
        let maximumLength = max(textLength - location, 0)
        let length = min(max(range.length, 0), maximumLength)

        return NSRange(location: location, length: length)
    }

    func clampedTextCenter(_ center: CGPoint) -> CGPoint {
        CGPoint(
            x: clampedNormalizedValue(center.x),
            y: clampedNormalizedValue(center.y)
        )
    }

    func clampedTextScale(_ scale: CGFloat) -> CGFloat {
        min(
            max(scale, MainEditLayout.textMinimumScale),
            MainEditLayout.textMaximumScale
        )
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
