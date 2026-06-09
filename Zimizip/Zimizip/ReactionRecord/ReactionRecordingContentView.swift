import SwiftUI

struct ReactionRecordingContentView: View {
    let surpriseCardPayload: SurpriseCardPayload
    let onStopButtonTap: () -> Void

    var body: some View {
        VStack(alignment: .center) {
            Spacer()

            ReactionRevealCardView(surpriseCardPayload: surpriseCardPayload)

            Spacer()

            ZimizipPrimaryButton(title: "완료하기") {
                onStopButtonTap()
            }
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
