import UIKit
import Flutter
import EmbraceIO

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Embrace SDK
        if let appId = loadEmbraceAppId() {
            do {
                try Embrace
                    .setup(
                        options: Embrace.Options(
                            appId: appId,
                            platform: .flutter
                        )
                    )
                    .start()
            } catch {
                print("Failed to initialize Embrace: \(error)")
            }
        } else {
            print("Embrace app ID not found. Create EmbraceConfig.plist from EmbraceConfig.plist.sample")
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func loadEmbraceAppId() -> String? {
        guard let path = Bundle.main.path(forResource: "EmbraceConfig", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let appId = config["AppId"] as? String,
              appId != "YOUR_EMBRACE_APP_ID" else {
            return nil
        }
        return appId
    }
}
