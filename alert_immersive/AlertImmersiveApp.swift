import SwiftUI
import RealityKit

@main
struct AlertImmersiveApp: App {
    @State private var appModel = AppModel()

    var body: some SwiftUI.Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }
        .defaultSize(width: 620, height: 420)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveAlertView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

@MainActor
@Observable
final class AppModel {
    let immersiveSpaceID = "AlertImmersiveSpace"
    var alertAcceptedCount = 0
}

struct ContentView: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    @State private var isImmersiveOpen = false
    var body: some View {
        VStack(spacing: 20) {
            Text("Immersive Alert Test")
                .font(.largeTitle)
                .bold()

            Text("같은 RealityView attachment alert를 WindowGroup과 ImmersiveSpace에서 비교합니다.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Immersive 열기") {
                    Task {
                        let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                        if case .opened = result {
                            isImmersiveOpen = true
                        }
                    }
                }

                Button("Immersive 닫기") {
                    Task {
                        await dismissImmersiveSpace()
                        isImmersiveOpen = false
                    }
                }
                .disabled(!isImmersiveOpen)
            }

            WindowAttachmentAlertView()
                .frame(width: 360, height: 220)
                .disabled(isImmersiveOpen)

            Text("Alert 확인 횟수: \(appModel.alertAcceptedCount)")
                .font(.headline)
        }
        .padding(48)
    }
}

struct WindowAttachmentAlertView: View {
    @Environment(AppModel.self) private var appModel
    @State private var isAlertPresented = false

    var body: some View {
        RealityView { content, attachments in
            if let panel = attachments.entity(for: "windowAlertPanel") {
                panel.position = SIMD3<Float>(0, 0, 0)
                content.add(panel)
            }
        } attachments: {
            Attachment(id: "windowAlertPanel") {
                VStack(spacing: 16) {
                    Text("WindowGroup 안의 attachment")
                        .font(.headline)

                    Button("Attachment Alert 띄우기") {
                        print("Window attachment button tapped")
                        isAlertPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(24)
                .glassBackgroundEffect()
                .alert("Window Attachment Alert", isPresented: $isAlertPresented) {
                    Button("취소", role: .cancel) {}

                    Button("확인") {
                        appModel.alertAcceptedCount += 1
                        print("Window attachment alert confirmed")
                    }
                } message: {
                    Text("이 alert는 WindowGroup 안의 RealityView attachment에 붙어 있습니다.")
                }
            }
        }
    }
}

struct ImmersiveAlertView: View {
    @Environment(AppModel.self) private var appModel
    @State private var isAlertPresented = false

    var body: some View {
        RealityView { content, attachments in
            if let panel = attachments.entity(for: "alertPanel") {
                panel.position = SIMD3<Float>(0, 1.35, -1.0)
                content.add(panel)
            }
        } attachments: {
            Attachment(id: "alertPanel") {
                VStack(spacing: 16) {
                    Text("ImmersiveSpace 안의 버튼")
                        .font(.title2)
                        .bold()

                    Button("Alert 띄우기") {
                        print("Immersive attachment button tapped")
                        isAlertPresented = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(28)
                .glassBackgroundEffect()
                .alert("Immersive Alert", isPresented: $isAlertPresented) {
                    Button("취소", role: .cancel) {}

                    Button("확인") {
                        appModel.alertAcceptedCount += 1
                        print("Immersive alert confirmed")
                    }
                } message: {
                    Text("이 alert는 ImmersiveSpace 안의 attachment View에 붙어 있습니다.")
                }
            }
        }
    }
}
