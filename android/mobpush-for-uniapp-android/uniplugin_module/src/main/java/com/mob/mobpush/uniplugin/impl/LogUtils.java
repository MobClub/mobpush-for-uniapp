package com.mob.mobpush.uniplugin.impl;

import android.util.Log;

public class LogUtils {
    public static boolean enableDebug = false;
    public static final String TAG = "MOBPUSH-UNI-PLUGIN";

    public static void log(String msg) {
        if (enableDebug) {
            Log.i(TAG, msg);
        }
    }

    public static void log(String msg, Throwable T) {
        if (enableDebug) {
            Log.e(TAG, msg, T);
        }
    }
}
