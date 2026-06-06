import SwiftUI

struct ReactionRecordingContentView: View {
    let onStopButtonTap: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Text("00:00:02")
                .font(.system(size: 18, design: .monospaced))
                .foregroundStyle(.white)
                .padding(5)
                .background(Color(red: 255/255, green: 0/255 , blue: 46/255))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Spacer()

            SurpriseContentFrameView {
                Image("Image")
                    .resizable()
                    .scaledToFit()
            }

            Spacer()

            Button {
                onStopButtonTap()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .glassEffect(.regular, in: Circle())
                        .shadow(color: Color(red: 232/255, green: 224/255, blue: 218/255), radius: 40, x: 2, y: 2)
                        .frame(width: 80, height: 80)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 255/255, green: 0/255 , blue: 46/255))
                        .frame(width: 36, height: 36)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 20)
        .padding(.bottom, 48)
    }
}

#Preview {
    ReactionRecordingContentView {}
}
