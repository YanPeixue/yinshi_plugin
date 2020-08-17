package com.app.yinshi_plugin;

import android.app.Application;
import android.util.Log;

import androidx.annotation.NonNull;

import com.videogo.exception.BaseException;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.bean.EZCameraInfo;
import com.videogo.openapi.bean.EZDeviceInfo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** YinshiPlugin */
public class YinshiPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Application application;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "yinshi_plugin");
    channel.setMethodCallHandler(this);

    application = (Application )flutterPluginBinding.getApplicationContext();

    BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();

    EventChannel eventChannel = new EventChannel(messenger, "rate");
    EventStreamHander streamHander = new EventStreamHander();
    eventChannel.setStreamHandler(streamHander);

    boolean success = flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("yinshi.player", new YingshiPluginFactory(messenger, streamHander));
    if (success) {
      System.out.println("注册视图成功");
    } else {
      System.out.println("注册视图失败");
    }
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {

    final MethodChannel channel = new MethodChannel(registrar.messenger(), "yinshi_plugin");
    channel.setMethodCallHandler(new YinshiPlugin());

    EventChannel eventChannel = new EventChannel(registrar.messenger(), "rate");
    EventStreamHander streamHander = new EventStreamHander();
    eventChannel.setStreamHandler(streamHander);

    boolean success = registrar.platformViewRegistry().registerViewFactory("yinshi.player", new YingshiPluginFactory(registrar.messenger(), streamHander));
    if (success) {
      System.out.println("注册视图成功");
    } else {
      System.out.println("注册视图失败");
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("register")) {

      EZOpenSDK.enableP2P(false);
      boolean success = EZOpenSDK.initLib(application, "4dd656b2aab84b4b88395722a3b71b7e");

      Map info = new HashMap();
      if (success) {
        info.put("error", 0);
        info.put("msg", "注册成功");
        Log.d("nice", "success");
      } else {
        info.put("error", -1);
        info.put("msg", "注册失败");
      }
      result.success(info);
    } else if(call.method.equals("setAccessToken")) {
      String accessToken = (String) call.arguments;
      EZOpenSDK.getInstance().setAccessToken(accessToken);
      Log.d("nice", "success");

      Map info = new HashMap();
      info.put("error", 0);
      info.put("msg", "设置成功");
      result.success(info);
    } else if (call.method.equals("getDeviceList")) {
      int page = (int)call.arguments;
      Log.i("页码数", String.valueOf(page));

      FutureTask<Map> task = new FutureTask<Map>(new Callable<Map>() {
        @Override
        public Map call() throws Exception {
          List<EZDeviceInfo> devices = EZOpenSDK.getInstance().getDeviceList(0, 10);
          System.out.println(devices);
          Map info = new HashMap();


          List items = new ArrayList();
          for (EZDeviceInfo deviceInfo : devices) {
            EZCameraInfo cameraInfo = deviceInfo.getCameraInfoList().get(0);
            System.out.println(deviceInfo.getDeviceName());
            Map device = new HashMap();
            device.put("deviceCover", deviceInfo.getDeviceCover());
            device.put("deviceName", deviceInfo.getDeviceName());
            device.put("deviceSerial", deviceInfo.getDeviceSerial());
            device.put("cameraNo", deviceInfo.getCameraNum());
            device.put("videoLevel", cameraInfo.getVideoLevel().getVideoLevel());
            device.put("isEncrypt", deviceInfo.getIsEncrypt());
            device.put("isSupportTalk", deviceInfo.isSupportTalk().getCapability());
            device.put("status", deviceInfo.getStatus());
            items.add(device);
          }
          info.put("msg", "获取设备成功");
          info.put("error", 0);
          info.put("data", items);
          return info;
        }
      });
      new Thread(task).start();

      try {
        result.success(task.get());
      } catch (ExecutionException e) {
        e.printStackTrace();
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
