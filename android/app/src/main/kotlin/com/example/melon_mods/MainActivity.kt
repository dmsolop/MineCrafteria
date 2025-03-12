package com.test.mods

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import androidx.core.content.FileProvider

class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.test.mods/file_opener"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setPackage("com.mojang.minecraftpe")
            val file = File(filePath)
            val fileUri = FileProvider.getUriForFile(this@MainActivity, BuildConfig.APPLICATION_ID + ".fileprovider", file)

            setDataAndType(fileUri, "application/octet-stream") // Use appropriate MIME type
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        }
    }
}
