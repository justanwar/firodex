package com.komodoplatform.atomicdex;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.BufferedOutputStream;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
    private EventChannel.EventSink logsSink;
    private final Handler logHandler = new Handler(Looper.getMainLooper());

    private boolean isSafBytes = false;
    private MethodChannel.Result safResult;
    private String safData;
    private byte[] safDataBytes;
    private static final int CREATE_SAF_FILE = 21;
    private static final String TAG_CREATE_SAF_FILE = "CREATE_SAF_FILE";

    static {
        System.loadLibrary("mm2-lib");
    }


    private void nativeC(FlutterEngine flutterEngine) {
        BinaryMessenger bm = flutterEngine.getDartExecutor().getBinaryMessenger();
        EventChannel logsChannel = new EventChannel(bm, "komodo-web-dex/event");
        logsChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                logsSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                logsSink = null;
            }
        });

        // https://flutter.dev/docs/development/platform-integration/platform-channels?tab=android-channel-kotlin-tab#step-3-add-an-android-platform-specific-implementation
        new MethodChannel(bm, "komodo-web-dex")
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "start": {
                            Map<String, String> arguments = call.arguments();
                            onStart(arguments, result);
                            break;
                        }
                        case "status": {
                            onStatus(result);
                            break;
                        }
                        case "stop": {
                            onStop(result);
                            break;
                        }
                        default: {
                            result.notImplemented();
                        }
                    }
                });

    }

    private void setupSaf(FlutterEngine flutterEngine) {
        BinaryMessenger bm = flutterEngine.getDartExecutor().getBinaryMessenger();
        new MethodChannel(bm, "komodo-web-dex/AndroidSAF")
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("saveFile")) {
                        Log.i(TAG_CREATE_SAF_FILE, "Triggered saveFile method");
                        if (call.arguments() == null) {
                            result.error("NEED_ARGUMENTS", "Not enough arguments", null);
                            return;
                        }
                        String ext = call.argument("ext");
                        String filetype = call.argument("filetype");
                        String filename = call.argument("filename");

                        Log.i(TAG_CREATE_SAF_FILE, String.format("File to save is %s.%s, of type %s", filename, ext, filetype));

                        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
                        intent.addCategory(Intent.CATEGORY_OPENABLE);
                        intent.setType(filetype);
                        intent.putExtra(Intent.EXTRA_TITLE, String.format("%s.%s", filename, ext));

                        safResult = result;
                        boolean isDataBytes = Boolean.TRUE.equals(call.argument("isDataBytes"));
                        if (isDataBytes) {
                            Log.i(TAG_CREATE_SAF_FILE, "Data to save is in BYTES format");
                            safDataBytes = call.argument("data");
                            isSafBytes = true;
                        } else {
                            Log.i(TAG_CREATE_SAF_FILE, "Data to save is in TEXT format");
                            safData = call.argument("data");
                            isSafBytes = false;
                        }
                        Log.i(TAG_CREATE_SAF_FILE, "Triggering file picker");
                        startActivityForResult(intent, CREATE_SAF_FILE);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode,
                                 Intent resultData) {
        // MRC: Needed so the custom SAF implementation doesn't break the file_picker plugin
        super.onActivityResult(requestCode, resultCode, resultData);

        if (requestCode == CREATE_SAF_FILE
                && resultCode == Activity.RESULT_OK) {
            Log.i(TAG_CREATE_SAF_FILE, "File picker finished");
            Uri uri;
            if (resultData != null) {
                Log.i(TAG_CREATE_SAF_FILE, "Grabbing URI returned from file picker");
                uri = resultData.getData();
                Log.d(TAG_CREATE_SAF_FILE, String.format("Target URI = %s", uri.toString()));
                try {
                    OutputStream outputStream = getContentResolver().openOutputStream(uri);
                    if (isSafBytes) {
                        Log.i(TAG_CREATE_SAF_FILE, "Starting saving data bytes");

                        BufferedOutputStream bufferedOutStream = new BufferedOutputStream(outputStream);
                        bufferedOutStream.write(safDataBytes);
                        bufferedOutStream.flush();
                        bufferedOutStream.close();
                        outputStream.close();
                    } else {
                        Log.i(TAG_CREATE_SAF_FILE, "Starting saving data as text");

                        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(outputStream));
                        writer.write(safData);
                        writer.flush();
                        writer.close();
                        outputStream.close();
                    }
                    Log.i(TAG_CREATE_SAF_FILE, "Successfully saved data");
                    safResult.success(true);
                } catch (IOException e) {
                    Log.i(TAG_CREATE_SAF_FILE, "An error happened while saving", e);
                    safResult.error("ERROR", "Could not write to file", e);
                }
            }
        }
        Log.i(TAG_CREATE_SAF_FILE, "Cleaning up...");
        safResult = null;
        safData = null;
        safDataBytes = null;
    }


    private void onStart(Map<String, String> arguments, MethodChannel.Result result) {

        if (arguments == null) {
            result.success(0);
            return;
        }
        String arg = arguments.get("params");
        if (arg == null) {
            result.success(0);
            return;
        }

        int ret = startMm2(arg);
        result.success(ret);
    }

    private void onStatus(MethodChannel.Result result) {
        int status = nativeMm2MainStatus();
        result.success(status);
    }

    private void onStop(MethodChannel.Result result) {
        int ret = nativeMm2Stop();
        result.success(ret);
    }

    private int startMm2(String conf) {

        sendLog("START MM2 --------------------------------");

        return nativeMm2Main(conf, this::sendLog);
    }

    private void sendLog(String line) {
        if (logsSink != null) {
            logHandler.post(() -> logsSink.success(line));

        }
    }

    /// Corresponds to Java_com_komodoplatform_atomicdex_MainActivity_nativeMm2MainStatus in main.cpp
    private native byte nativeMm2MainStatus();

    /// Corresponds to Java_com_komodoplatform_atomicdex_MainActivity_nativeMm2Main in main.cpp
    private native byte nativeMm2Main(String conf, JNILogListener listener);

    /// Corresponds to Java_com_komodoplatform_atomicdex_MainActivity_nativeMm2Stop in main.cpp
    private native byte nativeMm2Stop();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        nativeC(flutterEngine);
        setupSaf(flutterEngine);
    }
}

interface JNILogListener {
    void onLog(String line);
}