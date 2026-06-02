import SwiftUI

struct CameraManualControlsBar: View {
    let values: [CameraManualControl: String]
    let selectedControl: CameraManualControl?
    let onSelect: (CameraManualControl) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(CameraManualControl.allCases) { control in
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
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }

            VStack(spacing: 4) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 19, weight: .regular))

                Text("RESET")
                    .font(.system(size: 10.5, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 2)
        }
    }
}
