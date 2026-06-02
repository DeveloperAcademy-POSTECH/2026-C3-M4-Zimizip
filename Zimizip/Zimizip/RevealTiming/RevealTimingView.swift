import SwiftUI

struct RevealTimingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingReactionRecordGuide = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 255 / 255, green: 252 / 255, blue: 250 / 255)
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Spacer()
                            .frame(height: 75)
                        
                        Text("서프라이즈 카드가\n완성 되었어요!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                        Text("지금 바로 서프라이즈를 하거나,\n원하는 순간을 위해 보관할 수 있어요")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 181 / 255, green: 170 / 255, blue: 162 / 255))
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 60)

                    Button {
                        isShowingReactionRecordGuide = true
                    } label: {
                        OptionItemView(
                            icon: "MobileCamera",
                            title: "지금 바로 전하기",
                            subtitle: "상대방에게 바로 보여주고\n그 순간을 기록해요",
                            style: .revealTiming
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                        .frame(height: 20)

                    Button {
                    } label: {
                        OptionItemView(
                            icon: "CalendarClock",
                            title: "나중에 전하기",
                            subtitle: "앱에 저장해두고\n원하는 순간에 열어요",
                            style: .revealTiming
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $isShowingReactionRecordGuide) {
                ReactionRecordGuideView()
            }
        }
    }
}

#Preview {
    RevealTimingView()
}
