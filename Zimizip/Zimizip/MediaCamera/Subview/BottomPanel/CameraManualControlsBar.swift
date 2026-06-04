import SwiftUI

struct CameraManualControlsBar: View {
    let values: [CameraManualControl: String]
    let selectedControl: CameraManualControl?
    let disabledControls: Set<CameraManualControl>
    let onSelect: (CameraManualControl) -> Void
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(CameraManualControl.allCases) { control in
                let isDisabled = disabledControls.contains(control)

                Button {
                    onSelect(control)
                } label: {
                    VStack(spacing: 4) {
                        Text(control.title)
                            .font(.system(size: 13, weight: .semibold))

                        Text(values[control] ?? "AUTO")
                            .font(.system(size: 10.5, weight: .medium))
                    }
                    .foregroundStyle(selectedControl == control ? CameraUIConstants.accentColor : .white)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .padding(.bottom, 6)
                    .opacity(isDisabled ? 0.38 : 1.0)
                }
                .buttonStyle(.plain)
                .disabled(isDisabled)
                .frame(maxWidth: .infinity)
            }

            Button {
                onReset()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 19, weight: .regular))

                    Text("RESET")
                        .font(.system(size: 10.5, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
        }
    }
}
