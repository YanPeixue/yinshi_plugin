import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:yinshi_plugin/yinshi_plugin.dart';

class EzPlayerPage extends StatefulWidget {

  final String deviceSerial;
  final int cameraNo;
  @override
  _EzPlayerPageState createState() => _EzPlayerPageState();

  EzPlayerPage(this.deviceSerial, this.cameraNo);
}

class _EzPlayerPageState extends State<EzPlayerPage> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }
  @override
  Widget build(BuildContext context) {
    double pHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).size.width / 16 * 9;

    _animation = Tween(begin: MediaQuery.of(context).size.height, end: MediaQuery.of(context).size.width / 16 * 9).animate(_animationController)..addListener(() {
      setState(() {

      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("监控画面"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 16 * 9,
                color: Colors.red,
                width: MediaQuery.of(context).size.width,
                child: Platform.isIOS ? UiKitView(
                  viewType: "yinshi.player",
                  creationParams: <String, dynamic>{
                    "deviceSerial": widget.deviceSerial,
                    "cameraNo": widget.cameraNo
                  },
                  creationParamsCodec: StandardMessageCodec(),
                ) : AndroidView(
                    viewType: "yinshi.player",
                  creationParams: <String, dynamic>{
                    "deviceSerial": widget.deviceSerial,
                    "cameraNo": widget.cameraNo
                  },
                  creationParamsCodec: StandardMessageCodec(),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.orangeAccent,
                  alignment: Alignment.center,
                  child: Container(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  _animationController.forward();
                                  },
                                child: Column(
                                  children: [
                                    Icon(Icons.error),
                                    Text("云台")
                                  ],
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                  setState(() {
                                  });
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.error),
                                    Text("对讲")
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              RaisedButton(
                                onPressed: () {
                                  YinshiPlugin.captureImage().then((value) {
                                    print("Save");
                                    print(value["data"].runtimeType);
                                    if (value["error"] == 0) {
                                      ImageGallerySaver.saveImage(value["data"]);
                                    } else {
                                      print("save Fail");
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.error),
                                    Text("截图")
                                  ],
                                ),
                              ),
                              RaisedButton(
                                onPressed: () {
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.error),
                                    Text("录像")
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
            Positioned(
              child: Stack(
                children: [
                  Container(
                      color: Colors.green,
                      height: pHeight,
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      YinshiPlugin.ptzControlUp();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      YinshiPlugin.ptzControlLeft();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      YinshiPlugin.ptzControlRight();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      YinshiPlugin.ptzControlDown();
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )),
                  Positioned(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: RaisedButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _animationController.reverse();
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                    right: 10,
                    top: 10,
                  )
                ],
              ),
              top: _animation.value,
              left: 0,
              right: 0,
            )
          ],
        ));
  }
}
