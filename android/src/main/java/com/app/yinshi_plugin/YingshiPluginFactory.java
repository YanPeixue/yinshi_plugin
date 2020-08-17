package com.app.yinshi_plugin;

import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class YingshiPluginFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;
    private final EventStreamHander eventStreamHander;

    public YingshiPluginFactory(BinaryMessenger messenger, EventStreamHander eventStreamHander) {
        super(StandardMessageCodec.INSTANCE);

        System.out.println("走了YingshiPluginFactory");
        this.messenger = messenger;
        this.eventStreamHander = eventStreamHander;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map params = (Map<String, Object>) args;
        System.out.println("获取参数");
        return new YingshiPluginView(context, this.messenger, viewId, params, this.eventStreamHander);
    }
}
