package com.test.mods

import java.io.File
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.test.mods.CustomNativeAdFactory


class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.morph.mods.minecraft.addons/file_opener"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    // Factory registration
    GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "customNative", // Factory ID (will be used in Flutter)
            CustomNativeAdFactory(this)
    )

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call,
            result ->
      if (call.method == "openFileWithApp") {
        val filePath = call.argument<String>("filePath")
        openFileWithSpecificApp(filePath!!)
        result.success(null)
      } else {
        result.notImplemented()
      }
    }
  }

  private fun openFileWithSpecificApp(filePath: String) {
    val intent =
            Intent(Intent.ACTION_VIEW).apply {
              setPackage("com.mojang.minecraftpe")
              val file = File(filePath)
              val fileUri =
                      FileProvider.getUriForFile(
                              this@MainActivity,
                              BuildConfig.APPLICATION_ID + ".fileprovider",
                              file
                      )

              setDataAndType(fileUri, "application/octet-stream") // Use appropriate MIME type
              addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

    if (intent.resolveActivity(packageManager) != null) {
      startActivity(intent)
    }
  }
}
