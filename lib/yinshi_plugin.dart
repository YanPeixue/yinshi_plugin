import 'dart:async';

import 'package:flutter/services.dart';

class YinshiPlugin {
  static const MethodChannel _channel =
      const MethodChannel('yinshi_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map> initYsWithAppkey(String appkey) async {
    final Map reply = await _channel.invokeMethod("register", appkey);
    return reply;
  }

  static Future<Map> setYsAccessToken(String accessToken) async {
    final Map reply = await _channel.invokeMethod("setAccessToken", accessToken);
    return reply;
  }

  static void realToTalk(bool pressed) async {
    _channel.invokeMethod("realToTalk", pressed);
  }

  static void stopPlay() {
    _channel.invokeMethod("stop", null);
  }

  static void startPlay() {
    _channel.invokeMethod("start", null);
  }

  static void openSound() {
    _channel.invokeMethod("openVoice");
  }

  static void closeSound() {
    _channel.invokeMethod("closeVoice", null);
  }

  static Future<Map> getYsDeviceList(int page) async {
    final reply = await _channel.invokeMethod("getDeviceList", page);
    return reply;
  }

  static Future<Map> captureImage() async {
    final reply = await _channel.invokeMethod("captureImage", null);
    return reply;
  }

  static Future<bool> ptzControlLeft() async {
    final reply = await _channel.invokeMethod("commmondLeft", null);
    return reply;
  }

  static Future<bool> ptzControlUp() async {
    final reply = await _channel.invokeMethod("commmondUp", null);
    return reply;
  }

  static Future<bool> ptzControlDown() async {
    final reply = await _channel.invokeMethod("commmondDown", null);
    return reply;
  }

  static Future<bool> ptzControlRight() async {
    final reply = await _channel.invokeMethod("commmondRight", null);
    return reply;
  }

  static Future<bool> prepareTalking() async {
    await _channel.invokeMethod("prepareToTalk", null);
    return true;
  }

  static Future<bool> changeQuality(String level) async {
    final  reply = await _channel.invokeMethod("changeQuality", level);
    return reply;
  }

}
