import SwiftUI
import UIKit

struct MainEditFilterPanel: View {
    @Binding var selectedFilterPreset: MainEditFilterPreset

    let thumbnailImage: UIImage?
    let cancelAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            thumbnailPanel
            actionBar
        }
        .background(MainEditLayout.panelBackgroundColor)
    }
}

private extension MainEditFilterPanel {
    var thumbnailPanel: some View {
        HStack(alignment: .top) {
            let presets = MainEditFilterPreset.allCases
            ForEach(Array(presets.enumerated()), id: \.element.id) { index, preset in
                MainEditFilterThumbnail(
                    preset: preset,
                    thumbnailImage: thumbnailImage,
                    isSelected: selectedFilterPreset == preset
                ) {
                    selectedFilterPreset = preset
                }

                if index < presets.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(MainEditLayout.filterThumbnailPanelPadding)
        .frame(maxWidth: .infinity)
        .frame(height: MainEditLayout.filterThumbnailPanelHeight, alignment: .top)
        .background(MainEditLayout.panelBackgroundColor)
    }

    var actionBar: some View {
        HStack(alignment: .top) {
            Button(action: cancelAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color.baseWhite)
                    .frame(
                        width: MainEditLayout.filterActionIconSize,
                        height: MainEditLayout.filterActionIconSize
                    )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Text("필터")
                .font(.custom("Pretendard", size: 16).weight(.semibold))
                .foregroundStyle(Color.baseWhite)

            Spacer(minLength: 0)

            Button(action: confirmAction) {
                Image(systemName: "checkmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.brandPrimary)
                    .frame(
                        width: MainEditLayout.filterActionIconSize,
                        height: MainEditLayout.filterActionIconSize
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, MainEditLayout.filterActionBarHorizontalPadding)
        .padding(.top, 0)
        .padding(.bottom, MainEditLayout.filterActionBarBottomPadding)
        .background(MainEditLayout.panelBackgroundColor)
    }
}

private struct MainEditFilterThumbnail: View {
    let preset: MainEditFilterPreset
    let thumbnailImage: UIImage?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            thumbnail
        }
        .buttonStyle(.plain)
    }
}

private extension MainEditFilterThumbnail {
    var thumbnail: some View {
        ZStack(alignment: .bottom) {
            thumbnailContent
                .frame(
                    width: MainEditLayout.filterThumbnailSize.width,
                    height: MainEditLayout.filterThumbnailSize.height
                )
                .clipped()

            Text(preset.title)
                .font(.custom("Pretendard", size: 14).weight(isSelected ? .semibold : .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(labelColor)
                .frame(width: MainEditLayout.filterThumbnailSize.width, alignment: .center)
                .background(labelBackgroundColor)
        }
        .frame(
            width: MainEditLayout.filterThumbnailSize.width,
            height: MainEditLayout.filterThumbnailSize.height,
            alignment: .bottom
        )
        .overlay {
            if isSelected {
                Rectangle()
                    .stroke(Color.buttonSelectedLine, lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    var thumbnailContent: some View {
        if let thumbnailImage {
            Image(uiImage: thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.gray50
        }
    }

    var labelColor: Color {
        isSelected ? .brandPrimary : .gray400
    }

    var labelBackgroundColor: Color {
        isSelected ? .buttonSelected : .gray50
    }
}

#Preview {
    @Previewable @State var selectedFilterPreset: MainEditFilterPreset = .original

    MainEditFilterPanel(
        selectedFilterPreset: $selectedFilterPreset,
        thumbnailImage: nil,
        cancelAction: {},
        confirmAction: {}
    )
    .background(Color.black)
}
