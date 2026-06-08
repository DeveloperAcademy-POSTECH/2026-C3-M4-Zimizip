import SwiftUI

struct ReactionRecordGuideView: View {
    @State private var isShowingReactionRecord = false
    @State private var recordingErrorMessage: String?
    @State private var isStartingRecording = false
    @State private var screenRecorder = ReplayKitScreenRecorder()
    @State private var frontCameraRecorder = AVFoundationFrontCameraRecorder()

    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                
                Spacer()
                    .frame(height: 108)
                
                Text("시작하기 버튼을 누르고\n기기를 상대방에게 건네주세요")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.textPrimary)
                    .padding(.horizontal, 20)
                
                Spacer()
                    .frame(height: 16)

                Text("버튼을 누름과 동시에\n화면 및 전면 녹화가 시작됩니다")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray250)
                    .padding(.horizontal, 20)

                Spacer()

                ZimizipPrimaryButton(title: "시작하기") {
                    Task {
                        await startRecording()
                    }
                }
                    .padding(.bottom, 60)
                    .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $isShowingReactionRecord) {
            ReactionRecordView(
                screenRecorder: screenRecorder,
                frontCameraRecorder: frontCameraRecorder
            )
        }
        .alert(
            "녹화에 실패했어요",
            isPresented: Binding(
                get: { recordingErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        recordingErrorMessage = nil
                    }
                }
            )
        ) {
            Button("확인") {
                recordingErrorMessage = nil
            }
        } message: {
            Text(recordingErrorMessage ?? "")
        }
    }

    private func startRecording() async {
        guard !isStartingRecording else { return }
        isStartingRecording = true
        defer { isStartingRecording = false }

        do {
            try await frontCameraRecorder.startRecording()
            try await screenRecorder.startRecording()
            isShowingReactionRecord = true
        } catch {
            _ = try? await frontCameraRecorder.stopRecording()
            _ = try? await screenRecorder.stopRecording()
            recordingErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ReactionRecordGuideView()
}
