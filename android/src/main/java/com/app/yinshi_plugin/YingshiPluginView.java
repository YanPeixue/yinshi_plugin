package com.app.yinshi_plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Handler;
import android.os.Message;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;

import com.videogo.errorlayer.ErrorInfo;
import com.videogo.exception.BaseException;
import com.videogo.openapi.EZConstants;
import com.videogo.openapi.EZOpenSDK;
import com.videogo.openapi.EZPlayer;
import com.videogo.openapi.bean.EZCameraInfo;
import com.videogo.openapi.bean.EZDeviceInfo;
import com.videogo.util.SDCardUtil;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class YingshiPluginView extends Handler implements PlatformView, MethodChannel.MethodCallHandler, SurfaceHolder.Callback {

    private MethodChannel _channel;
    private EZPlayer _talkPlayer;
    private EZPlayer _player;

    private SurfaceView surfaceView;
    private SurfaceHolder surfaceHolder;
    private LinearLayout _view;
    private EventStreamHander eventStreamHander;
    private int WC = LinearLayout.LayoutParams.WRAP_CONTENT;

    private String deviceSerial;
    private int cameraNo;
    private int isSupportTalk;


    public YingshiPluginView(Context context, BinaryMessenger messenger, int id, Map params, EventStreamHander eventChannel) {
        System.out.println("准备视图");
        this.eventStreamHander = eventChannel;

        this.surfaceView = new SurfaceView(context);
        this.surfaceView.getHolder().addCallback(this);

        String deviceSerial = (String) params.get("deviceSerial");
        Integer cameraNo = (Integer) params.get("cameraNo");
        Integer isSupportTalk = (Integer) params.get("isSupportTalk");


        this.cameraNo = cameraNo;
        this.deviceSerial = deviceSerial;
        this.isSupportTalk = isSupportTalk;

        _channel = new MethodChannel(messenger, "yinshi_plugin");
        _channel.setMethodCallHandler(this);

        _view = new LinearLayout(context);
        _view.setBackgroundColor(Color.rgb(100, 200, 100));
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(WC, WC);
        _view.setLayoutParams(layoutParams);
        _view.addView(this.surfaceView);

        _talkPlayer = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
        _talkPlayer.setHandler(this);

        _player = EZOpenSDK.getInstance().createPlayer(deviceSerial, cameraNo);
        _player.setHandler(this);
        _player.startRealPlay();

    }

    @Override
    public View getView() {
        return _view;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void handleMessage(Message msg) {
        switch (msg.what) {
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_SUCCESS:
                //播放成功
                Map map = new HashMap();
                map.put("playstatus",true);
                eventStreamHander.sendEvent(map);
                System.out.println("开始播放");
                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_PLAY_FAIL:
                //播放失败,得到失败信息
                ErrorInfo errorinfo = (ErrorInfo) msg.obj;
                //得到播放失败错误码
                int code = errorinfo.errorCode;
                //得到播放失败模块错误码
                String codeStr = errorinfo.moduleCode;
                //得到播放失败描述
                String description = errorinfo.description;
                //得到播放失败解决方方案
                //String description = errorinfo.sulution;
                System.out.println("播放失败" + description);

                break;
            case EZConstants.EZRealPlayConstants.MSG_REALPLAY_CONNECTION_START:
                System.out.println("111111" + msg.obj);
                break;
            case EZConstants.MSG_VIDEO_SIZE_CHANGED:
                //解析出视频画面分辨率回调
                try {
                    String temp = (String) msg.obj;
                    String[] strings = temp.split(":");
                    int mVideoWidth = Integer.parseInt(strings[0]);
                    int mVideoHeight = Integer.parseInt(strings[1]);
                    //解析出视频分辨率
                    System.out.println("视频分辨率 ：" + mVideoHeight);
                    Map result = new HashMap();
                    result.put("rate", "2.1 MB/s");

                    eventStreamHander.sendEvent(result);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
            default:
                break;
        }
    }

    @Override
    public void onMethodCall(@NonNull final MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("captureImage")) {
            System.out.println("截图");
            if (!SDCardUtil.isSDCardUseable()) {
                // 提示SD卡不可用
                System.out.println("SD卡不可用");
                return;
            }

            if (SDCardUtil.getSDCardRemainSize() < SDCardUtil.PIC_MIN_MEM_SPACE) {
                // 提示内存不足
                System.out.println("内存不足");
                return;
            }

            Bitmap bitmap = _player.capturePicture();

            System.out.println(_player);
            Map info = new HashMap();
            //baos.toByteArray()
            if (bitmap == null) {
                info.put("error", -1);
                info.put("msg", "截屏失败");
            } else {
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                info.put("error", 0);
                info.put("msg", "截屏成功");
                info.put("data", baos.toByteArray());
            }
            result.success(info);
        } else if (call.method.equals("stop")) {
            _player.stopRealPlay();
        } else if (call.method.equals("start")) {
            _player.startRealPlay();
        } else if (call.method.equals("dispose")) {
            _player.release();
            _talkPlayer.release();
        } else if (call.method.equals("stopYinshiVideo")) {
            _player.stopRealPlay();

            if (_talkPlayer != null) {
                _talkPlayer.stopVoiceTalk();
            }
        } else if (call.method.equals("commmondLeft")) {
            FutureTask task = new FutureTask(new Callable() {
                @Override
                public Object call() throws Exception {
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandLeft,
                            EZConstants.EZPTZAction.EZPTZActionSTART, 1);
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandLeft,
                            EZConstants.EZPTZAction.EZPTZActionSTOP, 1);
                    return null;
                }
            });
            new Thread(task).start();

        } else if (call.method.equals("commmondRight")) {
            FutureTask task = new FutureTask(new Callable() {
                @Override
                public Object call() throws Exception {
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandRight,
                            EZConstants.EZPTZAction.EZPTZActionSTART, 1);
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandRight,
                            EZConstants.EZPTZAction.EZPTZActionSTOP, 1);
                    return null;
                }
            });
            new Thread(task).start();
        } else if (call.method.equals("commmondUp")) {
            FutureTask task = new FutureTask(new Callable() {
                @Override
                public Object call() throws Exception {
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandUp,
                            EZConstants.EZPTZAction.EZPTZActionSTART, 1);
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandUp,
                            EZConstants.EZPTZAction.EZPTZActionSTOP, 1);
                    return null;
                }
            });
            new Thread(task).start();
        } else if (call.method.equals("commmondDown")) {
            FutureTask task = new FutureTask(new Callable() {
                @Override
                public Object call() throws Exception {
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandDown,
                            EZConstants.EZPTZAction.EZPTZActionSTART, 1);
                    EZOpenSDK.getInstance().controlPTZ(deviceSerial, cameraNo, EZConstants.EZPTZCommand.EZPTZCommandDown,
                            EZConstants.EZPTZAction.EZPTZActionSTOP, 1);
                    return null;
                }
            });
            new Thread(task).start();
        } else if (call.method.equals("prepareToTalk")) {
            if (isSupportTalk != 1 && isSupportTalk != 3) {
                return;
            }
            _talkPlayer.startVoiceTalk();
        } else if (call.method.equals("realToTalk")) {
            boolean pressed = (boolean)call.arguments;
            _talkPlayer.setAudioOnly(pressed);
        } else if (call.method == "changeQuality") {
            FutureTask<Boolean> task = new FutureTask(new Callable() {
                @Override
                public Object call() throws Exception {
                    String level = (String) call.arguments;
                    EZConstants.EZVideoLevel type = EZConstants.EZVideoLevel.VIDEO_LEVEL_FLUNET;

                    if (level.equals("high")) {
                        type = EZConstants.EZVideoLevel.VIDEO_LEVEL_HD;
                    } else if (level.equals("mid")) {
                        type = EZConstants.EZVideoLevel.VIDEO_LEVEL_BALANCED;
                    } else {
                        type = EZConstants.EZVideoLevel.VIDEO_LEVEL_FLUNET;
                    }
                    boolean success = EZOpenSDK.getInstance().setVideoLevel(deviceSerial, cameraNo, type.getVideoLevel());

                    if (success) {
                        _player.stopRealPlay();
                        _player.startRealPlay();
                    }
                    return new Boolean(success);
                }
            });
            new Thread(task).start();

            try {
                result.success(task.get().booleanValue());
            } catch (ExecutionException e) {
                e.printStackTrace();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        } else if (call.method.equals("closeVoice")) {
            _player.closeSound();
        } else if (call.method.equals("openVoice")) {
            _player.openSound();
        }
    }

    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        if (_player != null) {
            _player.setSurfaceHold(surfaceHolder);
        }
        this.surfaceHolder = surfaceHolder;
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i1, int i2) {

    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        if (_player != null) {
            _player.setSurfaceHold(null);
        }
        this.surfaceHolder = null;
    }

}
