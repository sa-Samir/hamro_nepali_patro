import Flutter
import UIKit
import WidgetKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Lets flutter_local_notifications run plugins in its background action isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerNativeChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  private func registerNativeChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "com.nepali.patro/native", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "refreshAll":
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
      case "requestPinWidget":
        // iOS has no API to pin a widget programmatically.
        result(false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
