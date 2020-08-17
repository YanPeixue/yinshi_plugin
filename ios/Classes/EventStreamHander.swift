//
//  EventStreamHander.swift
//  yinshi_plugin
//
//  Created by Peixue Yan on 2020/8/10.
//

import Foundation

class EventStreamHander: FlutterStreamHandler {
    private var eventSink:FlutterEventSink? = nil
       func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
           eventSink = events
           return nil
       }
       
       func onCancel(withArguments arguments: Any?) -> FlutterError? {
           eventSink = nil
           return nil
       }
       
       //发送event
       public func sendEvent(event:Any) {
        eventSink?(event)
       }
}
