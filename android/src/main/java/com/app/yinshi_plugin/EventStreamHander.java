package com.app.yinshi_plugin;

import io.flutter.plugin.common.EventChannel;

public class EventStreamHander implements EventChannel.StreamHandler {

    private EventChannel.EventSink eventSink;
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    //发送event
    public void sendEvent(Object event) {
        eventSink.success(event);
    }
}
