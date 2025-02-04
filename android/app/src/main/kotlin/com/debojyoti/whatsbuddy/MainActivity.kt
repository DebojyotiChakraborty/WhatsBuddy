package com.debojyoti.whatsbuddy

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.DocumentsContract
import android.os.Environment
import java.io.File
import android.provider.MediaStore
import android.content.ContentValues
import java.io.OutputStream
import java.text.SimpleDateFormat
import java.util.*
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.debojyoti.whatsbuddy/status_files"
    private val REQUEST_CODE_OPEN_DIRECTORY = 1001
    private var pendingAccessResult: MethodChannel.Result? = null

    private fun getStatusFolderUri(): Uri? {
        val statusPath = Environment.getExternalStorageDirectory().path +
            "/Android/media/com.whatsapp/WhatsApp/Media/.Statuses"
        
        return try {
            val file = File(statusPath)
            if (file.exists()) {
                DocumentsContract.buildDocumentUriUsingTree(
                    Uri.parse("content://com.android.externalstorage.documents"),
                    "tree:primary:Android%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses"
                )
            } else {
                null
            }
        } catch (e: Exception) {
            null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "requestStatusFolderAccess" -> {
                    pendingAccessResult = result
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                    }
                    startActivityForResult(intent, 1234)
                }
                "getStatusFiles" -> {
                    val uri = call.argument<String>("uri") ?: run {
                        result.error("NO_URI", "No directory URI provided", null)
                        return@setMethodCallHandler
                    }
                    getFilesFromTreeUri(uri, result)
                }
                "getFileBytes" -> {
                    val uriString = call.argument<String>("uri") ?: run {
                        result.error("NO_URI", "No URI provided", null)
                        return@setMethodCallHandler
                    }
                    val uri = Uri.parse(uriString)
                    try {
                        val inputStream = contentResolver.openInputStream(uri)
                        val bytes = inputStream?.readBytes() ?: ByteArray(0)
                        result.success(bytes)
                    } catch (e: Exception) {
                        result.error("FILE_ERROR", e.message, null)
                    }
                }
                "saveFile" -> {
                    saveFile(call, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getFilesFromTreeUri(uriString: String, result: MethodChannel.Result) {
        try {
            val treeUri = Uri.parse(uriString)
            contentResolver.takePersistableUriPermission(
                treeUri, 
                Intent.FLAG_GRANT_READ_URI_PERMISSION or 
                Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            )

            val files = mutableListOf<String>()
            val docUri = DocumentsContract.buildDocumentUriUsingTree(
                treeUri, 
                DocumentsContract.getTreeDocumentId(treeUri)
            )

            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                DocumentsContract.getDocumentId(docUri)
            )

            val cursor = contentResolver.query(
                childrenUri,
                arrayOf(
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_SIZE
                ),
                null, null, null
            )

            cursor?.use {
                while (it.moveToNext()) {
                    val fileName = it.getString(0)
                    val fileSize = it.getLong(2)
                    if (isValidMediaFile(fileName) && fileSize > 0) {
                        val docId = it.getString(1)
                        val fileUri = DocumentsContract.buildDocumentUriUsingTree(
                            treeUri,
                            docId
                        )
                        files.add(fileUri.toString())
                    }
                }
            }

            result.success(files)
        } catch (e: Exception) {
            result.error("FILE_ERROR", e.message, null)
        }
    }

    private fun isValidMediaFile(fileName: String): Boolean {
        if (fileName.equals(".nomedia", ignoreCase = true)) return false
        if (fileName.startsWith(".")) return false // Skip hidden files
        
        val ext = fileName.substringAfterLast('.', "").lowercase()
        val validExtensions = setOf("jpg", "jpeg", "png", "webp", "mp4", "mov", "avi", "webm")
        return validExtensions.contains(ext)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1234) {
            if (resultCode == Activity.RESULT_OK) {
                data?.data?.let { uri ->
                    contentResolver.takePersistableUriPermission(
                        uri, 
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                    pendingAccessResult?.success(uri.toString())
                }
            } else {
                pendingAccessResult?.error("ACCESS_DENIED", "User denied access", null)
            }
            pendingAccessResult = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    private fun generateFileName(original: String, mimeType: String): String {
        val dateFormat = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault())
        val timestamp = dateFormat.format(Date())
        val extension = when {
            mimeType.startsWith("video/") -> "mp4"
            mimeType.startsWith("image/") -> {
                val ext = original.substringAfterLast(".", "jpg")
                if (ext.length > 4) "jpg" else ext
            }
            else -> "jpg"
        }
        return "whatsapp_status_$timestamp.$extension"
    }

    private fun saveFile(call: MethodCall, result: MethodChannel.Result) {
        val uriString = call.argument<String>("uri") ?: run {
            result.error("NO_URI", "No URI provided", null)
            return
        }
        val mimeType = call.argument<String>("mimeType") ?: "*/*"
        val originalName = call.argument<String>("fileName") ?: "file"
        
        try {
            val sourceUri = Uri.parse(uriString)
            val fileName = generateFileName(originalName, mimeType)
            
            val resolver = applicationContext.contentResolver
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + "/WhatsBuddy")
            }
            
            val collection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val destUri = resolver.insert(collection, values) ?: throw Exception("Failed to create file")
            
            resolver.openInputStream(sourceUri)?.use { input ->
                resolver.openOutputStream(destUri)?.use { output ->
                    input.copyTo(output)
                }
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("SAVE_ERROR", e.message, null)
        }
    }
}
