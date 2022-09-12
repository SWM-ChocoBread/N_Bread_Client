package com.example.chocobread

import co.ab180.airbridge.flutter.AirbridgeFlutter
import io.flutter.app.FlutterApplication

class MainApplication: FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        AirbridgeFlutter.init(this, "nbreadab", "c79bec17356745faabccb845fe6f8039")
    }
}