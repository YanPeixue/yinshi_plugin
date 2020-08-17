//
//  YinshiPluginView.swift
//  yinshi_plugin
//
//  Created by Peixue Yan on 2020/8/5.
//

import UIKit
import EZOpenSDKFramework

class YinshiPluginView: NSObject, FlutterPlatformView {

    lazy var playerView = UIView.init()
    var deviceSerial : String!
    var cameraNo = 0
    var player : EZPlayer!
    var _talkPlayer : EZPlayer!
    var _channel : FlutterMethodChannel!
    var isSupportTalk : Int!
//    var _eventChannel : FlutterEventChannel!

    var eventStreamHandler: EventStreamHander?

    init(_ frame: CGRect, viewId: Int64, args: Any,  messager: FlutterBinaryMessenger, eventHandle: EventStreamHander) {
        super.init()
        
        let params = args as! NSDictionary
        let deviceSerial = params["deviceSerial"] as! String
        let cameraNo = params["cameraNo"] as! Int
        let isSupportTalk = params["isSupportTalk"] as! Int
        
        self.deviceSerial = deviceSerial
        self.cameraNo = cameraNo;
        self.isSupportTalk = isSupportTalk
        self.eventStreamHandler = eventHandle
        
        _channel = FlutterMethodChannel(name: "yinshi_plugin", binaryMessenger: messager)
        _channel.setMethodCallHandler { (call, result) in
            self.onMethodCall(call, result: result)
        }

//        let eventChannel = FlutterEventChannel.init(name: "rate", binaryMessenger:messager)
//        //设置handler，初学swift，是不是有其它写法？
//        eventChannel.setStreamHandler((eventStreamHandler as! FlutterStreamHandler & NSObjectProtocol))
//
//
        self.playerView  = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        self.playerView.backgroundColor = .red
        
        _talkPlayer = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial, cameraNo: cameraNo)
        _talkPlayer.delegate = self
        player = EZOpenSDK.createPlayer(withDeviceSerial: deviceSerial, cameraNo: cameraNo)
        player.backgroundModeByPlayer = true
        player.delegate = self
        player.setPlayerView(self.playerView)
        player.startRealPlay()
    }
    
    func view() -> UIView {
        return self.playerView
    }
    
    func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult)  {
        print(call.method)
        if (call.method == "captureImage") {
            let image = player.capturePicture(100)
            var info = Dictionary<String, Any>()
            
            if image == nil {
                info["error"] = -1
                info["msg"]   = "截屏失败"
            } else {
                let data = (image?.jpegData(compressionQuality: 1.0))!
                let bytes = FlutterStandardTypedData(bytes: data)
                info["error"] = 0
                info["msg"]   = "截屏成功"
                info["data"]  = bytes
            }
            result(info)
            
        } else if (call.method == "stop") {
            player.stopRealPlay()
        } else if (call.method == "start") {
            player.startRealPlay()
        } else if (call.method == "dispose") {
            EZOpenSDK.release(_talkPlayer)
            EZOpenSDK.release(player)
        } else if (call.method == "stopYinshiVideo") {
            player.stopRealPlay()
            if _talkPlayer != nil {
                _talkPlayer.stopVoiceTalk()
            }
        } else if (call.method == "commmondLeft") {
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.left, action: EZPTZAction.start, speed: 2) { (error) in
                          
                      }
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.left, action: EZPTZAction.stop, speed: 2) { (error) in
                
            }
        } else if (call.method == "commmondRight") {
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.right, action: EZPTZAction.start, speed: 2) { (error) in
                        
                    }
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.right, action: EZPTZAction.stop, speed: 2) { (error) in
                
            }
        } else if (call.method == "commmondUp") {
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.up, action: EZPTZAction.start, speed: 2) { (error) in
                          
                      }
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.up, action: EZPTZAction.stop, speed: 2) { (error) in
                
            }
        } else if (call.method == "commmondDown") {
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.down, action: EZPTZAction.start, speed: 2) { (error) in
                         
                     }
            EZOpenSDK.controlPTZ(deviceSerial, cameraNo: cameraNo, command: EZPTZCommand.down, action: EZPTZAction.stop, speed: 2) { (error) in
                
            }
        } else if (call.method == "prepareToTalk") {
            if self.isSupportTalk != 1 && self.isSupportTalk != 3 {
                return;
            }
            _talkPlayer.startVoiceTalk();
        } else if (call.method == "realToTalk") {
            let pressed = call.arguments as! Bool
            
            _talkPlayer.audioTalkPressed(pressed)
        } else if (call.method == "changeQuality") {
            let level = call.arguments as! String
            var type  = EZVideoLevelType.low
            
            if level == "high" {
                type = EZVideoLevelType.high
            } else if level == "mid" {
                type = EZVideoLevelType.middle
            } else {
                type = EZVideoLevelType.low
            }
            EZOpenSDK.setVideoLevel(deviceSerial, cameraNo: cameraNo, videoLevel: type) { (error) in
                if (error != nil) {
                    result(false)
                } else {
                    self.player.stopRealPlay()
                    self.player.startRealPlay()
                    result(true)
                }
            }
        } else if (call.method == "closeVoice") {
            player.closeSound()
        } else if (call.method == "openVoice") {
            player.openSound()
        }
    }
    
}

extension YinshiPluginView : EZPlayerDelegate {
    
    func player(_ player: EZPlayer!, didPlayFailed error: Error!) {
        player.stopRealPlay()
    }
    
    func player(_ player: EZPlayer!, didReceivedDataLength dataLength: Int) {
        var value = Float(dataLength)/1024.0
        var fromatStr = "%.1f KB/s"

        if (value > 1024)
        {
            value = value/1024
            fromatStr = "%.1f MB/s"
        }
        eventStreamHandler?.sendEvent(event: ["rate": String.init(format: fromatStr, value)])
    }
    
    func player(_ player: EZPlayer!, didReceivedMessage messageCode: Int) {
        if (messageCode == EZMessageCode.PLAYER_REALPLAY_START.rawValue) {
            eventStreamHandler?.sendEvent(event: ["playstatus": true])
        } else if (messageCode == EZMessageCode.PLAYER_VOICE_TALK_START.rawValue) {
            player.closeSound()
        } else if (messageCode == EZMessageCode.PLAYER_VOICE_TALK_END.rawValue) {
            player.openSound()
        } else if (messageCode == EZMessageCode.PLAYER_NET_CHANGED.rawValue) {
            player.stopRealPlay()
            player.startRealPlay()
        }
    }
}
