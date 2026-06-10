import SwiftUI

struct ReactionRecordingContentView: View {
    @State private var revealRatio = 0.0

    let surpriseCardPayload: SurpriseCardPayload
    let onStopButtonTap: () -> Void

    private var isStopButtonEnabled: Bool {
        revealRatio >= 0.8
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            ReactionRevealCardView(surpriseCardPayload: surpriseCardPayload) { revealRatio in
                self.revealRatio = revealRatio
            }

            Spacer()

            ZimizipPrimaryButton(
                title: "완료하기",
                backgroundColor: isStopButtonEnabled ? .brandPrimary : Color(red: 153 / 255, green: 153 / 255, blue: 153 / 255)
            ) {
                onStopButtonTap()
            }
            .disabled(!isStopButtonEnabled)
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 48)
    }
}

#Preview {
    ReactionRecordingContentView(
        surpriseCardPayload: .previewValue
    ) {}
}
