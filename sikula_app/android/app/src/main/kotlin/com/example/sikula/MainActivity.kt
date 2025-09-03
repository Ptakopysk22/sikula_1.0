package com.example.sikula

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NfcAdapter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var nfcAdapter: NfcAdapter? = null
    private lateinit var pendingIntent: PendingIntent
    private val CHANNEL = "com.example.sikula/nfc"
    private lateinit var flutterEngine: FlutterEngine

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        println("MainActivity onCreate called")

        // Initialize FlutterEngine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getNfcData") {
                val nfcId = call.arguments as? String
                if (nfcId != null) {
                    println("NFC ID received in Kotlin: $nfcId")
                    result.success(nfcId)
                } else {
                    result.error("NULL_NFC_ID", "NFC ID is null", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // Set up NFC
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP), PendingIntent.FLAG_MUTABLE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getNfcData") {
                val nfcId = call.arguments as? String
                if (nfcId != null) {
                    println("NFC ID received in Kotlin: $nfcId")
                    result.success(nfcId)
                } else {
                    result.error("NULL_NFC_ID", "NFC ID is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        println("MainActivity onResume called")
        nfcAdapter?.enableForegroundDispatch(
            this, pendingIntent, arrayOf(IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED)), null
        )
    }

    override fun onPause() {
        super.onPause()
        println("MainActivity onPause called")
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        println("MainActivity onNewIntent called with action: ${intent.action}")
        if (NfcAdapter.ACTION_TAG_DISCOVERED == intent.action) {
            val nfcId = intent.getByteArrayExtra(NfcAdapter.EXTRA_ID)?.joinToString("") { "%02x".format(it) }
            println("NFC tag discovered with ID: $nfcId")
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("getNfcData", nfcId ?: "")
        }
    }
}


