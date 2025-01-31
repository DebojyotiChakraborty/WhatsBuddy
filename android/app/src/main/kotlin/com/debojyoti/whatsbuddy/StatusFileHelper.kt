package com.debojyoti.whatsbuddy

import android.content.Context
import java.io.File

class StatusFileHelper(private val context: Context) {
    fun getStatusFiles(): List<String> {
        val statusPaths = listOf(
            "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
            "/storage/emulated/0/WhatsApp/Media/.Statuses"
        )

        val files = mutableListOf<String>()
        
        for (path in statusPaths) {
            val directory = File(path)
            if (directory.exists() && directory.isDirectory) {
                directory.listFiles()?.forEach { file ->
                    if (file.isFile && isMediaFile(file.name)) {
                        files.add(file.absolutePath)
                    }
                }
            }
        }
        
        return files
    }

    private fun isMediaFile(fileName: String): Boolean {
        val lowercase = fileName.toLowerCase()
        return lowercase.endsWith(".jpg") ||
               lowercase.endsWith(".jpeg") ||
               lowercase.endsWith(".png") ||
               lowercase.endsWith(".mp4") ||
               lowercase.endsWith(".gif")
    }
} 