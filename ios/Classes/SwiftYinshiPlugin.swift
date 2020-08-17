import Flutter
import UIKit
import EZOpenSDKFramework
import MJExtension

public class SwiftYinshiPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "yinshi_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftYinshiPlugin()
        let eventStreamHandler = EventStreamHander()

        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel.init(name: "rate", binaryMessenger:registrar.messenger())
        eventChannel.setStreamHandler((eventStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
        
        registrar.register(YinshiPluginFactory(messager: registrar.messenger(), eventHandle: eventStreamHandler), withId: "yinshi.player")
        

    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getDeviceList") {
            let page = call.arguments as! Int
            
            EZOpenSDK.getDeviceList(page, pageSize: 10) { (deviceList, totalCount, error) in
                var info = Dictionary<String, Any>()
            //EZUserInfo.mj_keyValuesArray(withObjectArray: deviceList)
                 if (error != nil) {
                    info["error"] = -1
                    info["msg"]   = "获取设备失败"
                 } else {
                    info["msg"]   = "获取设备成功"
                    info["error"] = 0
                    let devices = NSMutableArray()
                    
                    if deviceList != nil {
                        for item in deviceList as! [EZDeviceInfo] {
                            
                            let camera = item.cameraInfo.first as! EZCameraInfo
                            
                            let device = NSMutableDictionary()
                            device["deviceCover"] = item.deviceCover
                            device["deviceName"] = item.deviceName
                            device["deviceSerial"] = camera.deviceSerial
                            device["cameraNo"] = camera.cameraNo
                            device["videoLevel"] = camera.videoLevel
                            device["isEncrypt"] = item.isEncrypt
                            device["isSupportTalk"] = item.isSupportTalk
                            device["status"] = item.status;
                            devices.add(device)
                        }
                    }
                    
                    
                    info["data"]  = devices
                 }
                result(info)
             }
        } else if (call.method == "register") {
            let success = registerToYs()
            var info = Dictionary<String, Any>()
            if (success) {
                info["error"] = 0
                info["msg"]   = "注册成功"
            } else {
                info["error"] = -1
                info["msg"]   = "注册失败"
            }
            result(info)
        } else if (call.method == "setAccessToken") {
            let token = call.arguments as! String
            setAccessToken(token: token)
            
            var info = Dictionary<String, Any>()
            info["error"] = 0
            info["msg"]   = "设置成功"
            result(info)
        } else {
            result("iOS " + UIDevice.current.systemVersion)
        }
    }

    public func registerToYs() -> Bool {
        return EZOpenSDK.initLib(withAppKey: "4dd656b2aab84b4b88395722a3b71b7e")
    }
    
    //授权登录后，设置token
    public func setAccessToken(token: String) -> Void {
        if (!token.isEmpty) {
            EZOpenSDK.setAccessToken(token)
        }
    }
}
