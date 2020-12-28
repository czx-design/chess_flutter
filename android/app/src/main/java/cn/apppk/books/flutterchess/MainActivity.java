package cn.apppk.books.flutterchess;

import android.os.Bundle;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String ENGINE_CHANNEL = "cn.apppk.chessroad/engine";

    private CChessEngine engine;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        engine = new CChessEngine();

        FlutterEngine fe = getFlutterEngine();
        if (fe == null) return;

        MethodChannel methodChannel =
                new MethodChannel(fe.getDartExecutor(), ENGINE_CHANNEL);

        // 对接 Flutter 侧对 Mehtod Channel 的调用
        methodChannel.setMethodCallHandler((call, result) -> {

                    switch (call.method) {

                        case "startup":
                            result.success(engine.startup());
                            break;

                        case "send":
                            result.success(engine.send(call.arguments.toString()));
                            break;

                        case "read":
                            result.success(engine.read());
                            break;

                        case "shutdown":
                            result.success(engine.shutdown());
                            break;

                        case "isReady":
                            result.success(engine.isReady());
                            break;

                        case "isThinking":
                            result.success(engine.isThinking());
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                }
        );
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);
    }
}