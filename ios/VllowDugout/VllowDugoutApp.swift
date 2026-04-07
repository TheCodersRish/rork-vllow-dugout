import SwiftUI
import SwiftData
import FirebaseAuth
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
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: path) {
            FirebaseApp.configure(options: options)
        } else {
            FirebaseApp.configure()
        }
        _authViewModel = State(wrappedValue: AuthViewModel())
    }

    var body: some Scene {
        WindowGroup {
            RootView(authViewModel: authViewModel)
                .onOpenURL { url in
                    _ = Auth.auth().canHandle(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
