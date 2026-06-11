import AVFoundation
import SwiftUI
import UIKit

struct ReactionRecordGuideView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var isShowingReactionRecord = false
    @State private var recordingErrorMessage: String?
    @State private var isStartingRecording = false
    @State private var isShowingReactionRecordPermissionSettingsPrompt = false
    @State private var didOpenReactionRecordPermissionSettings = false
    @State private var screenRecorder = SampleBufferReactionVideoRecorder()

    let surpriseCardPayload: SurpriseCardPayload

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
                
                Spacer()
                    .frame(height: 16)

                Text("버튼을 누름과 동시에\n화면 및 전면 녹화가 시작됩니다")
                    .font(.system(size: 18))
                    .foregroundStyle(.gray250)

                Spacer()
                
                Image("CharacterReactionGuide")
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                Text("녹화는 2분 후 자동으로 종료됩니다")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.gray250)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 12)


                ZimizipPrimaryButton(title: "시작하기") {
                    Task {
                        await startRecording()
                    }
                }
                .padding(.bottom, 60)
            }
            .padding(.horizontal, 20)

            if isShowingReactionRecordPermissionSettingsPrompt {
                PermissionSettingsPrompt(
                    title: "리액션 영상 녹화를 위해 권한이 필요합니다",
                    message: "카메라 및 마이크 접근을 허용하면 리액션 영상에 상대방의 모습과 목소리를 함께 담을 수 있습니다 ‘설정’에서 마이크 접근을 허용해 주십시오",
                    onMoveToSettings: moveToReactionRecordPermissionSettings,
                    onLater: {
                        isShowingReactionRecordPermissionSettingsPrompt = false
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .navigationDestination(isPresented: $isShowingReactionRecord) {
            ReactionRecordView(
                surpriseCardPayload: surpriseCardPayload,
                screenRecorder: screenRecorder
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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, didOpenReactionRecordPermissionSettings else {
                return
            }

            Task {
                await refreshReactionRecordAccessAfterReturningFromSettings()
            }
        }
    }

    private func startRecording() async {
        guard !isStartingRecording else { return }
        isStartingRecording = true
        defer { isStartingRecording = false }

        do {
            let hasPermission = await requestReactionRecordAccess()
            guard hasPermission else {
                isShowingReactionRecordPermissionSettingsPrompt = true
                return
            }

            print("[ReactionRecordGuide] start button tapped. starting recorder")
            try await screenRecorder.startRecording()
            print("[ReactionRecordGuide] recorder start completed. navigating to ReactionRecordView")
            isShowingReactionRecord = true
        } catch {
            print("[ReactionRecordGuide] recorder start failed: \(error.localizedDescription)")
            _ = try? await screenRecorder.stopRecording()
            recordingErrorMessage = error.localizedDescription
        }
    }

    private func requestReactionRecordAccess() async -> Bool {
        let isCameraAuthorized = await requestCameraAccess()
        guard isCameraAuthorized else {
            return false
        }

        let isMicrophoneAuthorized = await requestMicrophoneAccess()

        return isMicrophoneAuthorized
    }

    private func requestCameraAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { isGranted in
                    continuation.resume(returning: isGranted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func requestMicrophoneAccess() async -> Bool {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return true
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { isGranted in
                    continuation.resume(returning: isGranted)
                }
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private func moveToReactionRecordPermissionSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        didOpenReactionRecordPermissionSettings = true
        UIApplication.shared.open(settingsURL) { didOpen in
            if !didOpen {
                Task { @MainActor in
                    didOpenReactionRecordPermissionSettings = false
                }
            }
        }
    }

    private func refreshReactionRecordAccessAfterReturningFromSettings() async {
        didOpenReactionRecordPermissionSettings = false

        let hasPermission = await requestReactionRecordAccess()
        isShowingReactionRecordPermissionSettingsPrompt = !hasPermission
    }
}

#Preview {
    ReactionRecordGuideView(surpriseCardPayload: .previewValue)
}
