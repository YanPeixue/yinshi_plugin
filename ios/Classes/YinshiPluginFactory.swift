//
//  YinshiPluginFactory.swift
//  yinshi_plugin
//
//  Created by Peixue Yan on 2020/8/5.
//

import UIKit

class YinshiPluginFactory: NSObject, FlutterPlatformViewFactory {
    let _messager : FlutterBinaryMessenger
    let _eventHandle: EventStreamHander
    init(messager : FlutterBinaryMessenger, eventHandle: EventStreamHander) {
        _messager = messager
        _eventHandle = eventHandle
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return YinshiPluginView(frame, viewId: viewId, args: args!, messager: _messager, eventHandle: _eventHandle)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
