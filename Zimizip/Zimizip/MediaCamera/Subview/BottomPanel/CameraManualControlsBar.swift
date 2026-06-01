import SwiftUI

struct CameraManualControlsBar: View {
    let values: [CameraManualControl: String]
    @Binding var selectedControl: CameraManualControl?
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(CameraManualControl.allCases) { control in
                Button {
                    if selectedControl == control {
                        selectedControl = nil
                    } else {
                        selectedControl = control
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text(control.title)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedControl == control ? CameraUIConstants.accentColor : .white)

                        Text(values[control] ?? "AUTO")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(selectedControl == control ? CameraUIConstants.accentColor : .white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 6)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(selectedControl == control ? CameraUIConstants.accentColor : .clear)
                            .frame(height: 2)
                    }
                }
                .buttonStyle(.plain)
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
                .foregroundStyle(.white)
                .frame(width: 58)
                .padding(.bottom, 2)
            }
            .buttonStyle(.plain)
        }
    }
}
