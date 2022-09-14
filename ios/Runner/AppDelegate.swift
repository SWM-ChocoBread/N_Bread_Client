import UIKit
import Flutter
import airbridge_flutter_sdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  // override func application(
  //   _ application: UIApplication,
  //   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  // ) -> Bool {
    // GeneratedPluginRegistrant.register(with: self)
    // return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  // }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    AirbridgeFlutter.initSDK(appName: "nbreadab", appToken: "c79bec17356745faabccb845fe6f8039", withLaunchOptions: launchOptions)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}


