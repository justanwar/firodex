import UIKit
import Flutter
import Foundation
import CoreLocation
import os.log
import UserNotifications
import AVFoundation

var mm2StartArgs: String?
var shouldRestartMM2: Bool = true;
var eventSink: FlutterEventSink?

func flutterLog(_ log: String) {
    eventSink?("{\"type\": \"log\", \"message\": \"\(log)\"}")
}

func mm2Callback(line: UnsafePointer<Int8>?) {
    if let lineStr = line {
        let logMessage = String(cString: lineStr)
        flutterLog(logMessage)
    }
}

func performMM2Start() -> Int32 {
    flutterLog("START MM2 --------------------------------")
    let error = Int32(mm2_main(mm2StartArgs, mm2Callback))
    flutterLog("START MM2 RESULT: \(error) ---------------")
    return error
}

func performMM2Stop() -> Int32 {
    flutterLog("STOP MM2 --------------------------------");
    let error = Int32(mm2_stop());
    flutterLog("STOP MM2 RESULT: \(error) ---------------");
    return error;
}

func performMM2Restart() -> Int32 {
    let _ = performMM2Stop()
    var ticker: Int = 0
    // wait until mm2 stopped, but continue after 3s anyway
    while(mm2_main_status() != 0 && ticker < 30) {
        usleep(100000) // 0.1s
        ticker += 1
    }
    
    let error = performMM2Start()
    ticker = 0
    // wait until mm2 started, but continue after 10s anyway
    while(mm2_main_status() != 3 && ticker < 100) {
        usleep(100000) // 0.1s
        ticker += 1
    }
    
    return error;
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    var intentURI: String?
    
    
    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        self.intentURI = url.absoluteString
        return true
    }
    
    override func application (_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let vc = window?.rootViewController as? FlutterViewController else {
            fatalError ("rootViewController is not type FlutterViewController")}
        let vcbm = vc as! FlutterBinaryMessenger
        
        let channelMain = FlutterMethodChannel (name: "komodo-web-dex", binaryMessenger: vcbm)
        let eventChannel = FlutterEventChannel (name: "komodo-web-dex/event", binaryMessenger: vcbm)
        eventChannel.setStreamHandler (self)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notifications allowed!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        channelMain.setMethodCallHandler ({(call: FlutterMethodCall, result: FlutterResult) -> Void in
            if call.method == "start" {
                guard let arg = (call.arguments as! Dictionary<String,String>)["params"] else { result(0); return }
                mm2StartArgs = arg;
                let error: Int32 = performMM2Start();
                
                result(error)
            } else if call.method == "status" {
                let ret = Int32(mm2_main_status());
                result(ret)
            } else if call.method == "stop" {
                mm2StartArgs = nil;
                let error: Int32 = performMM2Stop();
                
                result(error)
            }  else if call.method == "restart" {
                let error: Int32 = performMM2Restart();
                
                result(error)
            } else {result (FlutterMethodNotImplemented)}})
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    @objc func onDidReceiveData(_ notification:Notification) {
        if let data = notification.userInfo as? [String: String]
        {
            flutterLog(data["log"]!)
        }
        
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .didReceiveData, object: nil)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }
    
    public override func applicationWillResignActive(_ application: UIApplication) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window!.frame
        blurEffectView.tag = 61007
        
        self.window?.addSubview(blurEffectView)
    }
    
    public override func applicationDidBecomeActive(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN);
        self.window?.viewWithTag(61007)?.removeFromSuperview()
        
        eventSink?("{\"type\": \"app_did_become_active\"}")
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        signal(SIGPIPE, SIG_IGN);
    }
}

extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}
