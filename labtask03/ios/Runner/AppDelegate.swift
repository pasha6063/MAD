import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

  private let CHANNEL = "platformchannel.companyname.com/deviceinfo"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    let deviceInfoChannel = FlutterMethodChannel(
        name: CHANNEL,
        binaryMessenger: controller.binaryMessenger
    )

    deviceInfoChannel.setMethodCallHandler { [weak self] call, result in
      if call.method == "getDeviceInfo" {
        result(self?.getDeviceInfo())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getDeviceInfo() -> String {
      let device = UIDevice.current

      return """
      Device: \(device.name)
      Manufacturer: Apple
      Model: \(device.model)
      System Name: \(device.systemName)
      System Version: \(device.systemVersion)
      """
  }
}
