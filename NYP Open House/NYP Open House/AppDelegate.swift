import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        FirebaseApp.configure()

        if let opts = FirebaseApp.app()?.options {
            print("🔥 Firebase debug:")
            print("  ProjectID:", opts.projectID ?? "nil")
            print("  AppID:", opts.googleAppID)
            print("  DB URL:", opts.databaseURL ?? "nil")
        } else {
            print("⚠️ Firebase debug: FirebaseApp.app() is NIL (Firebase not configured?)")
        }

        return true
    }
}
