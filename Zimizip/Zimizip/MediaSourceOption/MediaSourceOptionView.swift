import Photos
import PhotosUI
import SwiftUI
import UIKit

struct MediaSourceOptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    @State private var selectedMedia: PhotosPickerItem?
    @State private var mediaEditInput: MediaEditInput?
    @State private var isShowingCamera = false
    @State private var isShowingPhotoPicker = false
    @State private var isShowingPhotoLibraryPermissionSettingsPrompt = false
    @State private var didOpenPhotoLibraryPermissionSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 255 / 255, green: 252 / 255, blue: 250 / 255)
                    .ignoresSafeArea()

                VStack(alignment: .leading) {
                    ZimizipBackButton()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("어떤 방식으로\n시작해볼까요?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Color(red: 36 / 255, green: 33 / 255, blue: 31 / 255))

                        Text("서프라이즈 사진을 준비하는\n방법을 선택해주세요")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(red: 129 / 255, green: 121 / 255, blue: 115 / 255))
                            .lineSpacing(4)
                    }
                    .padding(.bottom, 60)

                    Button {
                        isShowingCamera = true
                    } label: {
                        OptionItemView(
                            icon: "Camera",
                            title: "직접 촬영하기",
                            subtitle: "서프라이즈를 할 순간을\n바로 담아보세요"
                        )
                    }
                    .buttonStyle(OptionItemButtonStyle())

                    Spacer()
                        .frame(height: 20)

                    Button {
                        Task {
                            await openPhotoPickerAfterAuthorizationRequest()
                        }
                    } label: {
                        OptionItemView(
                            icon: "Image",
                            title: "갤러리에서 불러오기",
                            subtitle: "이미 저장된 사진으로\n시작해보세요"
                        )
                    }
                    .buttonStyle(OptionItemButtonStyle())

                    Spacer()
                }
                .padding(.horizontal, 20)

                if isShowingPhotoLibraryPermissionSettingsPrompt {
                    PermissionSettingsPrompt(
                        title: "서프라이즈 사진 선택과 리액션 영상\n저장을 위해 권한이 필요합니다",
                        message: "사진 접근을 허용하면 서프라이즈 사진을 불러오고, 완성된 리액션 영상을 사진 보관함에 저장할 수 있습니다.",
                        onMoveToSettings: moveToPhotoLibraryPermissionSettings,
                        onLater: {
                            isShowingPhotoLibraryPermissionSettingsPrompt = false
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .photosPicker(
                isPresented: $isShowingPhotoPicker,
                selection: $selectedMedia,
                matching: .images,
                photoLibrary: .shared()
            )
            .navigationDestination(item: $mediaEditInput) { mediaEditInput in
                MediaEditView(
                    media: mediaEditInput.source,
                    sourcePreviewFrame: mediaEditInput.sourcePreviewFrame,
                    isLandscapeCapture: mediaEditInput.isLandscapeCapture
                )
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)
            }
            .fullScreenCover(isPresented: $isShowingCamera) {
                MediaCameraView { photoData, previewFrame, isLandscapeCapture in
                    mediaEditInput = MediaEditInput(
                        source: photoData,
                        sourcePreviewFrame: previewFrame,
                        isLandscapeCapture: isLandscapeCapture
                    )
                }
            }
        }
        .task(id: selectedMedia) {
            guard let selectedMediaSource = try? await selectedMedia?.loadTransferable(type: Data.self) else {
                return
            }

            mediaEditInput = MediaEditInput(source: selectedMediaSource)
            selectedMedia = nil
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active, didOpenPhotoLibraryPermissionSettings else {
                return
            }

            Task {
                await refreshPhotoLibraryAccessAfterReturningFromSettings()
            }
        }
    }

    private func openPhotoPickerAfterAuthorizationRequest() async {
        let isAuthorized = await requestPhotoLibraryAccess()

        isShowingPhotoLibraryPermissionSettingsPrompt = !isAuthorized
        isShowingPhotoPicker = isAuthorized
    }

    private func requestPhotoLibraryAccess() async -> Bool {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return status == .authorized || status == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }

    private func moveToPhotoLibraryPermissionSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        didOpenPhotoLibraryPermissionSettings = true
        UIApplication.shared.open(settingsURL) { didOpen in
            if !didOpen {
                Task { @MainActor in
                    didOpenPhotoLibraryPermissionSettings = false
                }
            }
        }
    }

    private func refreshPhotoLibraryAccessAfterReturningFromSettings() async {
        didOpenPhotoLibraryPermissionSettings = false

        let isAuthorized = await requestPhotoLibraryAccess()
        isShowingPhotoLibraryPermissionSettingsPrompt = !isAuthorized
        isShowingPhotoPicker = isAuthorized
    }
}

#Preview {
    MediaSourceOptionView()
}
