import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:yinshi_plugin/yinshi_plugin.dart';

class EzPlayerPage extends StatefulWidget {

  final String deviceSerial;
  final int cameraNo;
  final int isSupportTalk;
  final String deviceName;

  @override
  _EzPlayerPageState createState() => _EzPlayerPageState();

  EzPlayerPage(this.deviceSerial, this.cameraNo, this.isSupportTalk, {this.deviceName});
}

class _EzPlayerPageState extends State<EzPlayerPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  bool isTalkPress = false;
  bool isTalkHighLight = false;
  bool isTalking = false;

  String hdText = "高清";
  String rateText = "0.0KB/s";
  bool isPlaying = false;
  bool openVoice = true;

  final _eventChannel = EventChannel("rate", const StandardMethodCodec());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    YinshiPlugin.destroyPlayer();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
  }

  void changeOrientation() {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);
    } else {
      // 强制横屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }
  }

  // 数据接收
  void _onEvent(Object value) {
    Map json = value;
    if (json.containsKey("playstatus")) {
      setState(() {
        print("开始播放");
        isPlaying = json["playstatus"];
      });
    } else {
      setState(() {
        rateText = json["rate"];
      });
    }
  }

  // 错误处理
  void _onError(dynamic) {}

  @override
  Widget build(BuildContext context) {
    double pHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).size.width / 16 * 9;

    _animation = Tween(
            begin: MediaQuery.of(context).size.height,
            end: MediaQuery.of(context).size.width / 16 * 9)
        .animate(_animationController)
          ..addListener(() {
            setState(() {});
          });
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.deviceName ?? "监控画面", style: TextStyle(fontSize: 16),),
        ),
        body:
        MediaQuery.of(context).orientation == Orientation.landscape ?
            Column(
              children: [
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.width / 16 * 9,
                    width: MediaQuery.of(context).size.width,
                    child: Platform.isIOS ? UiKitView(
                      viewType: "yinshi.player",
                      creationParams: <String, dynamic>{
                        "deviceSerial": widget.deviceSerial,
                        "cameraNo": widget.cameraNo,
                        "isSupportTalk": widget.isSupportTalk
                      },
                      creationParamsCodec: StandardMessageCodec(),
                    ) : AndroidView(
                      viewType: "yinshi.player",
                      creationParams: <String, dynamic>{
                        "deviceSerial": widget.deviceSerial,
                        "cameraNo": widget.cameraNo,
                        "isSupportTalk": widget.isSupportTalk
                      },
                      creationParamsCodec: StandardMessageCodec(),
                    ),
                  ),
                ),
                Container(
                  height: 37,
                  color: Colors.black87,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 38,
                          height: 38,
                          child: FlatButton(
                              onPressed: playButtonClick,
                              padding: EdgeInsets.zero,
                              child: Image(
                                  image: AssetImage(isPlaying ? "images/preview_stopplay_btn.png":
                                  "images/preview_play_btn.png")))),
                      Container(
                        width: 38,
                        height: 38,
                        child: FlatButton(
                            onPressed: voicePressd,
                            padding: EdgeInsets.zero,
                            child: Image(
                                image: AssetImage( openVoice ?
                                "images/preview_voice_btn.png" : "images/preview_unvoice_btn.png"))),
                      ),
                      PopupMenuButton(
                        child: Text(
                          hdText,
                          style: TextStyle(color: Colors.white),
                        ),
                        initialValue: "high",
                        padding: EdgeInsets.zero,
                        itemBuilder: (c) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              child: Text("高清"),
                              value: "high",
                            ),
                            PopupMenuItem<String>(
                              child: Text("均衡"),
                              value: "mid",
                            ),
                            PopupMenuItem<String>(
                              child: Text("流畅"),
                              value: "low",
                            ),
                          ];
                        },
                        onSelected: (value) {
                          switch (value) {
                            case "high":
                              hdText = "高清";
                              break;
                            case "mid":
                              hdText = "均衡";
                              break;
                            case "low":
                              hdText = "流畅";
                              break;
                          }

                          YinshiPlugin.changeQuality(value).then((change) {
                            if (change) {
                              setState(() {});
                            }
                          });
                        },
                      ),
                      Text(
                        rateText,
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                          width: 38,
                          height: 38,
                          child: Container(
                            width: 38,
                            height: 38,
                            child: FlatButton(
                              onPressed: changeOrientation,
                              padding: EdgeInsets.zero,
                              child: Image(
                                  image: AssetImage("images/preview_enlarge.png")),
                            ),
                          )
                      )],
                  ),
                ),
              ],
            ) :
        Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.width / 16 * 9,
                  width: MediaQuery.of(context).size.width,
                  child: Platform.isIOS ? UiKitView(
                    viewType: "yinshi.player",
                    creationParams: <String, dynamic>{
                      "deviceSerial": widget.deviceSerial,
                      "cameraNo": widget.cameraNo,
                      "isSupportTalk": widget.isSupportTalk
                    },
                    creationParamsCodec: StandardMessageCodec(),
                  ) : AndroidView(
                    viewType: "yinshi.player",
                    creationParams: <String, dynamic>{
                      "deviceSerial": widget.deviceSerial,
                      "cameraNo": widget.cameraNo,
                      "isSupportTalk": widget.isSupportTalk
                    },
                    creationParamsCodec: StandardMessageCodec(),
                  ),
                ),
                Container(
                  height: 37,
                  color: Colors.black87,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                          width: 38,
                          height: 38,
                          child: FlatButton(
                              onPressed: playButtonClick,
                              padding: EdgeInsets.zero,
                              child: Image(
                                  image: AssetImage(isPlaying ? "images/preview_stopplay_btn.png":
                                      "images/preview_play_btn.png")))),
                      Container(
                        width: 38,
                        height: 38,
                        child: FlatButton(
                            onPressed: voicePressd,
                            padding: EdgeInsets.zero,
                            child: Image(
                                image: AssetImage( openVoice ?
                                    "images/preview_voice_btn.png" : "images/preview_unvoice_btn.png"))),
                      ),
                      PopupMenuButton(
                        child: Text(
                          hdText,
                          style: TextStyle(color: Colors.white),
                        ),
                        initialValue: "high",
                        padding: EdgeInsets.zero,
                        itemBuilder: (c) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem<String>(
                              child: Text("高清"),
                              value: "high",
                            ),
                            PopupMenuItem<String>(
                              child: Text("均衡"),
                              value: "mid",
                            ),
                            PopupMenuItem<String>(
                              child: Text("流畅"),
                              value: "low",
                            ),
                          ];
                        },
                        onSelected: (value) {
                          switch (value) {
                            case "high":
                              hdText = "高清";
                              break;
                            case "mid":
                              hdText = "均衡";
                              break;
                            case "low":
                              hdText = "流畅";
                              break;
                          }

                          YinshiPlugin.changeQuality(value).then((change) {
                            if (change) {
                              setState(() {});
                            }
                          });
                        },
                      ),
                      Text(
                        rateText,
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        child: Container(
                          width: 38,
                          height: 38,
                          child: FlatButton(
                              onPressed: () {
                                // 强制横屏
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.landscapeLeft,
                                  DeviceOrientation.landscapeRight
                                ]);
                              },
                              padding: EdgeInsets.zero,
                              child: Image(
                                  image: AssetImage("images/preview_enlarge.png")),
                        ),
                      )
                      )],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width - 200) / 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            FlatButton(
                              color: Colors.white,
                              onPressed: () {
                                isTalkPress = false;
                                _animationController.forward();
                              },
                              child: Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "images/preview_barrel.png",
                                    ),
                                    width: 65,
                                    height: 65,
                                  ),
                                  Text("云台")
                                ],
                              ),
                            ),
                            FlatButton(
                              color: Colors.white,
                              onPressed: () {
                                isTalkPress = true;
                                YinshiPlugin.prepareTalking();
                                _animationController.forward();
                              },
                              child: Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "images/preview_talkback.png",
                                    ),
                                    width: 65,
                                    height: 65,
                                  ),
                                  Text("对讲")
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            FlatButton(
                              color: Colors.white,
                              onPressed: () {
                                YinshiPlugin.captureImage().then((value) {
                                  print("Save");
                                  print(value);
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
                                  Image(
                                    image: AssetImage(
                                      "images/preview_screenshot.png",
                                    ),
                                    width: 65,
                                    height: 65,
                                  ),
                                  Text("截图")
                                ],
                              ),
                            ),
                            FlatButton(
                              color: Colors.white,
                              onPressed: () {},
                              child: Column(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "images/preview_recording.png",
                                    ),
                                    width: 65,
                                    height: 65,
                                  ),
                                  Text("录像")
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              child: Stack(
                children: isTalkPress
                    ? [
                        Container(
                          color: Colors.white,
                          height: pHeight,
                          child: Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: FlatButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  setState(() {
                                    isTalking = !isTalking;
                                  });
                                  YinshiPlugin.realToTalk(isTalking);
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onHighlightChanged: (value) {
                                  setState(() {
                                    isTalkHighLight = !isTalkHighLight;
                                  });
                                },
                                child: Image(
                                    image: isTalking
                                        ? AssetImage("images/spkImg.png")
                                        : AssetImage(isTalkHighLight
                                            ? "images/preview_talkback_sel.png"
                                            : "images/preview_talkback.png")),
                              ),
                            ),
                          ),
                        ),
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
                      ]
                    : [
                        Container(
                            color: Colors.white,
                            height: pHeight,
                            child: Center(
                              child: Container(
                                width: 154,
                                height: 154,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("images/ptz_bg.png")),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            YinshiPlugin.ptzControlUp();
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            width: 50,
                                            height: 50,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            YinshiPlugin.ptzControlLeft();
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            YinshiPlugin.ptzControlRight();
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            YinshiPlugin.ptzControlDown();
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            color: Colors.transparent,
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

  void voicePressd() {
    if (openVoice) {
      YinshiPlugin.closeSound();
    } else {
      YinshiPlugin.openSound();
    }
    setState(() {
      openVoice = !openVoice;
    });
  }

  void playButtonClick() {
    if (isPlaying) {
      YinshiPlugin.stopPlay();
    } else {
      YinshiPlugin.startPlay();
    }
    print("change");

    setState(() {
      isPlaying = !isPlaying;
    });
  }
}
