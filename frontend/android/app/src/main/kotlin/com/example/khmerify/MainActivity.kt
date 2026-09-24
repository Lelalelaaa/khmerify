package com.example.khmerify

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.khmerify/keyboard"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "openKeyboardSettings" -> {
                    val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                }
                "isKeyboardEnabled" -> {
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                    val enabledList = imm?.enabledInputMethodList ?: emptyList()
                    val isEnabled = enabledList.any { it.packageName == packageName }
                    result.success(isEnabled)
                }
                "showKeyboardPicker" -> {
                    val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
                    imm?.showInputMethodPicker()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
