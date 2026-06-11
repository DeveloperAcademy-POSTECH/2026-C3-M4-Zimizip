import SwiftData
import SwiftUI

struct RevealTimingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isShowingReactionRecordGuide = false
    @State private var isShowingHome = false
    @State private var didSaveSurpriseProject = false

    let surpriseCardPayload: SurpriseCardPayload

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Spacer()
                            .frame(height: 108)
                        
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
                            subtitle: "상대방에게 바로 보여주고\n그 순간을 기록해요"
                        )
                    }
                    .buttonStyle(OptionItemButtonStyle())

                    Spacer()
                        .frame(height: 20)

                    Button {
                        saveSurpriseProjectForLater()
                    } label: {
                        OptionItemView(
                            icon: "CalendarClock",
                            title: "나중에 전하기",
                            subtitle: "앱에 저장해두고\n원하는 순간에 열어요"
                        )
                    }
                    .buttonStyle(OptionItemButtonStyle())

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $isShowingReactionRecordGuide) {
                ReactionRecordGuideView(surpriseCardPayload: surpriseCardPayload)
                    .navigationBarBackButtonHidden(true)
            }
            .fullScreenCover(isPresented: $isShowingHome) {
                HomeView()
            }
        }
    }

    private func saveSurpriseProjectForLater() {
        guard !didSaveSurpriseProject else {
            isShowingHome = true
            return
        }

        let surpriseProject = SurpriseProject(
            name: surpriseCardPayload.title,
            content: Content(
                media: Media(source: surpriseCardPayload.framingResult.source),
                box: surpriseCardPayload.coverImageName
            ),
            reactionContents: []
        )

        modelContext.insert(surpriseProject)

        do {
            try modelContext.save()
            didSaveSurpriseProject = true
            isShowingHome = true
        } catch {
            print("[RevealTiming] failed to save surprise project for later: \(error.localizedDescription)")
        }
    }
}

#Preview {
    RevealTimingView(surpriseCardPayload: .previewValue)
        .modelContainer(ArchivePreviewData.modelContainer())
}
