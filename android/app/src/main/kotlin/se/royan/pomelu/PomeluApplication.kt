package se.royan.pomelu

import android.app.Application

/** Starts Firebase before FCM delivers to a process it started itself. */
class PomeluApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        PushBridge.start(this)
    }
}
