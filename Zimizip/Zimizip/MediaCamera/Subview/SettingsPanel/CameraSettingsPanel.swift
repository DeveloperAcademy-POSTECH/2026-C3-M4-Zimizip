import SwiftUI

struct CameraSettingsPanel: View {
    let selectedQuickSetting: CameraQuickSetting
    @Binding var selectedAspectRatio: CameraAspectRatioOption
    @Binding var selectedTimer: CameraTimerOption
    @Binding var gridMode: CameraGridMode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(panelTitle)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)

            Divider()
                .overlay(Color.white.opacity(0.12))

            switch selectedQuickSetting {
            case .aspectRatio:
                optionRow(
                    CameraAspectRatioOption.allCases,
                    selection: selectedAspectRatio
                ) { option in
                    withAnimation(.easeInOut(duration: 0.24)) {
                        selectedAspectRatio = option
                    }
                } label: { $0.title }
            case .timer:
                optionRow(
                    CameraTimerOption.allCases,
                    selection: selectedTimer
                ) { selectedTimer = $0 } label: { $0.title }
            case .grid:
                HStack(spacing: 10) {
                    ForEach(CameraGridMode.allCases) { option in
                        Button {
                            gridMode = option
                        } label: {
                            VStack(spacing: 7) {
                                gridIcon(for: option)
                                    .foregroundStyle(gridMode == option ? CameraUIConstants.accentColor : .white)

                                Rectangle()
                                    .fill(gridMode == option ? CameraUIConstants.accentColor : .clear)
                                    .frame(width: 32, height: 2)
                            }
                            .frame(width: 48)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(12)
        .frame(maxWidth: 188)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var panelTitle: String {
        switch selectedQuickSetting {
        case .aspectRatio:
            "Aspect Ratio"
        case .timer:
            "Timer"
        case .grid:
            "Grid"
        }
    }

    private func optionRow<Option: Identifiable & Equatable>(
        _ options: [Option],
        selection: Option,
        action: @escaping (Option) -> Void,
        label: @escaping (Option) -> String
    ) -> some View {
        HStack(spacing: 10) {
            ForEach(options) { option in
                Button {
                    action(option)
                } label: {
                    VStack(spacing: 6) {
                        Text(label(option))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(selection == option ? CameraUIConstants.accentColor : .white)

                        Rectangle()
                            .fill(selection == option ? CameraUIConstants.accentColor : .clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func gridIcon(for option: CameraGridMode) -> some View {
        switch option {
        case .off:
            Image(systemName: "nosign")
                .font(.system(size: 18, weight: .regular))
        case .thirds:
            GridIcon(columns: 2, rows: 2)
        case .golden:
            GoldenGridIcon()
        }
    }
}

private struct GridIcon: View {
    let columns: Int
    let rows: Int

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let columnWidth = width / CGFloat(columns)
                let rowHeight = height / CGFloat(rows)

                path.addRect(CGRect(origin: .zero, size: geometry.size))

                for index in 1..<columns {
                    let x = columnWidth * CGFloat(index)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }

                for index in 1..<rows {
                    let y = rowHeight * CGFloat(index)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
        }
        .frame(width: 18, height: 18)
    }
}

private struct GoldenGridIcon: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let firstX = width * 0.62
            let secondX = width * 0.82
            let firstY = height * 0.72

            Path { path in
                path.addRect(CGRect(origin: .zero, size: geometry.size))
                path.move(to: CGPoint(x: firstX, y: 0))
                path.addLine(to: CGPoint(x: firstX, y: height))
                path.move(to: CGPoint(x: secondX, y: firstY))
                path.addLine(to: CGPoint(x: secondX, y: height))
                path.move(to: CGPoint(x: 0, y: firstY))
                path.addLine(to: CGPoint(x: width, y: firstY))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
        }
        .frame(width: 18, height: 18)
    }
}
