package com.iptv.azul

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "main_activity_channel"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        flutterEngine?.dartExecutor?.let {
            MethodChannel(it.binaryMessenger, "gdpr_plugin").setMethodCallHandler(
                GdprPlugin(this)
            )
        }

        MethodChannel(flutterEngine!!.dartExecutor, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getData") {
                val dd = resources.getString(R.string.unique_key)
                result.success(dd)
            }
        }
    }
}

