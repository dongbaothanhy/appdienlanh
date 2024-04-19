import UIKit
import Flutter
import Firebase
import AppTrackingTransparency 
import GoogleMobileAds
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as! UNUserNotificationCenterDelegate
      }

    // Disables Publisher first-party ID, formerly known as same app key.
    GADMobileAds.sharedInstance().requestConfiguration.setSameAppKeyEnabled(false)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {        
        if #available(iOS 15.0, *) {
           ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
           // Tracking authorization completed. Start loading ads here.
           // loadAd 
           })
        }
       }
  }
