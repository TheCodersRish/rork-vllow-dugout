import SwiftUI

struct RootView: View {
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.authState {
            case .onboarding:
                OnboardingFlowView {
                    authViewModel.completeOnboarding()
                }
                .transition(.opacity)

            case .auth:
                AuthView(authViewModel: authViewModel)
                    .transition(.opacity)

            case .main:
                ContentView(authViewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authViewModel.authState)
    }
}
