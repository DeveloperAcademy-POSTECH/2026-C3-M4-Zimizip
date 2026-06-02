import SwiftUI

struct CameraManualControlsBar: View {
    let values: [CameraManualControl: String]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(CameraManualControl.allCases) { control in
                VStack(spacing: 4) {
                    Text(control.title)
                        .font(.system(size: 13, weight: .semibold))

                    Text(values[control] ?? "AUTO")
                        .font(.system(size: 10.5, weight: .medium))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 6)
            }

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
    }
}
