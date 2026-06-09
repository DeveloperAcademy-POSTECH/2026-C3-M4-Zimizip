import SwiftUI

private enum AppStartRoute {
    case splash
    case introduction
    case home
}

struct ContentView: View {
    @State private var appStartRoute: AppStartRoute = .splash

    var body: some View {
        switch appStartRoute {
        case .splash:
            SplashView {
                appStartRoute = .introduction
            }

        case .introduction:
            IntroductionView {
                appStartRoute = .home
            }

        case .home:
            HomeView()
        }
    }
}

#Preview {
    ContentView()
}
