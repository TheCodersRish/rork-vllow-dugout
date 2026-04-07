import SwiftUI
import SwiftData
import FirebaseCore

@main
struct VllowDugoutApp: App {
    @State private var authViewModel: AuthViewModel

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        FirebaseApp.configure()
        _authViewModel = State(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView(authViewModel: authViewModel)
        }
        .modelContainer(sharedModelContainer)
    }
}
