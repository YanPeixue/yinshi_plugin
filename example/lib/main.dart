import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:yinshi_plugin/ez_player_page.dart';
import 'package:yinshi_plugin/yinshi_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List items = List();

  @override
  void initState() {
    super.initState();
    initPlatformState();

    getDeviceList();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await YinshiPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView.separated(
            itemBuilder: (context, index) {
              Map json = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return EzPlayerPage(json["deviceSerial"], json["cameraNo"], json["isSupportTalk"]);
                  }));
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 45,
                  child: Text(json["deviceName"]),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(height: 0.5,);
            },
            itemCount: items.length
        ),
      ),
    );
  }

  void getDeviceList() {
    YinshiPlugin.initYsWithAppkey("").then((value) {
      print("初始化萤石云" + value["msg"]);
    });

    YinshiPlugin.setYsAccessToken("ra.4b0ymbcfd170yfgobz7oo8hc8yazjjl8-708niqhpcu-0o49tkh-n5kdy9aym").then((value) {
      print(value);

      YinshiPlugin.getYsDeviceList(0).then((data) {
        print(value);
        for (Map json in data["data"]) {
          items.add(json);
        }
        setState(() {});
      });
    });
  }
  
}
