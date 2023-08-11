package com.iptv.azul


import android.app.Activity
import com.google.android.ump.ConsentDebugSettings
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.ConsentInformation
import com.google.android.ump.UserMessagingPlatform
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class GdprPlugin(private val activity: Activity?) : MethodCallHandler {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "gdpr_plugin")
            channel.setMethodCallHandler(GdprPlugin(registrar.activity()))
        }
    }

    private val TAG = "GdprPlugin"
    private lateinit var consentInformation: ConsentInformation

    init {
        initConsentInformation()
    }

    private fun initConsentInformation() {
        val debugSettings = ConsentDebugSettings.Builder(activity)
            .addTestDeviceHashedId("TEST-DEVICE-HASHED-ID")
            .build()

        val params = ConsentRequestParameters.Builder()
            .setConsentDebugSettings(debugSettings)
            .build()

        consentInformation = UserMessagingPlatform.getConsentInformation(activity)
        consentInformation.requestConsentInfoUpdate(
            activity,
            params,
            {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(
                    activity,
                    {
                        // Handle consent form dismissal
                    }
                )
            },
            {
                    requestConsentError ->
                // Handle request consent error
            }
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "showConsentForm" -> {
                UserMessagingPlatform.loadAndShowConsentFormIfRequired(
                    activity,
                    {
                        // Handle consent form dismissal
                    }
                )
            }
            else -> result.notImplemented()
        }
    }
}
