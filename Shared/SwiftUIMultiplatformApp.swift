
import SwiftUI
@main
struct SwiftUIMultiplatformApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
#if !os(tvOS)
        .commands {
            SidebarCommands()
        }
#endif
    }
}
