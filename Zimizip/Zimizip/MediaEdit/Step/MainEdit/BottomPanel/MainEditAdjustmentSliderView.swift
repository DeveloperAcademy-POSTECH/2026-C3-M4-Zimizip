import SwiftUI

struct MainEditAdjustmentSliderView: View {
    @Binding var value: Int

    private let minimumValue = -100
    private let maximumValue = 100

    var body: some View {
        HStack(alignment: .center, spacing: MainEditLayout.adjustmentSliderContentSpacing) {
            Text("\(value)")
                .font(.custom("Pretendard", size: MainEditLayout.adjustmentSliderValueFontSize).weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white)
                .frame(width: MainEditLayout.adjustmentSliderValueWidth, alignment: .center)

            sliderTrack
        }
        .padding(.horizontal, MainEditLayout.adjustmentSliderHorizontalPadding)
        .padding(.vertical, MainEditLayout.adjustmentSliderVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: MainEditLayout.adjustmentSliderHeight, alignment: .center)
        .background(MainEditLayout.bottomPanelBackgroundColor)
        .onAppear {
            value = clampedValue(value)
        }
    }
}

private extension MainEditAdjustmentSliderView {
    var sliderTrack: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray150)
                    .frame(height: MainEditLayout.adjustmentSliderTrackHeight)

                Circle()
                    .fill(Color.white)
                    .frame(
                        width: MainEditLayout.adjustmentSliderThumbSize,
                        height: MainEditLayout.adjustmentSliderThumbSize
                    )
                    .offset(x: thumbOffset(in: proxy.size.width))
            }
            .frame(height: MainEditLayout.adjustmentSliderThumbSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(
                            with: gesture.location.x,
                            trackWidth: proxy.size.width
                        )
                    }
            )
        }
        .frame(height: MainEditLayout.adjustmentSliderThumbSize)
    }

    func thumbOffset(in trackWidth: CGFloat) -> CGFloat {
        let thumbHalfWidth = MainEditLayout.adjustmentSliderThumbSize / 2
        let normalizedValue = CGFloat(value - minimumValue) / CGFloat(maximumValue - minimumValue)
        let centerX = normalizedValue * trackWidth

        return centerX - thumbHalfWidth
    }

    func updateValue(with locationX: CGFloat, trackWidth: CGFloat) {
        guard trackWidth > 0 else {
            return
        }

        let clampedLocationX = min(max(locationX, 0), trackWidth)
        let normalizedValue = clampedLocationX / trackWidth
        let newValue = minimumValue + Int((normalizedValue * CGFloat(maximumValue - minimumValue)).rounded())

        value = clampedValue(newValue)
    }

    func clampedValue(_ value: Int) -> Int {
        min(max(value, minimumValue), maximumValue)
    }
}

#Preview {
    @Previewable @State var value = 0

    VStack(spacing: 16) {
        MainEditAdjustmentSliderView(value: $value)

        MainEditAdjustmentSliderView(value: .constant(68))
    }
    .background(Color.black)
}
