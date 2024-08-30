package com.example.google_maps

import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "fake_location"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val messenger = flutterEngine?.dartExecutor?.binaryMessenger
        if (messenger != null) {
            MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
                when (call.method) {
                    "fakeLocation" -> {
                        val latitude = call.argument<Double>("latitude") ?: 0.0
                        val longitude = call.argument<Double>("longitude") ?: 0.0
                        if (false) {
                            // Redirect to developer settings to enable mock locations
                            val intent = Intent(Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS)
                            startActivity(intent)
                            result.success("Redirecting to Developer Settings")
                        } else {
                            setMockLocation(latitude, longitude)
                            result.success("Location faked")
                        }
                    }

                    "stopFakeLocation" -> {
                        stopMockLocation()
                        result.success("Stopped mock location")
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun isMockLocationEnabled(): Boolean {
        try {
            val mockLocationApp = Settings.Secure.getString(contentResolver, "mock_location_app")
            val packageName = applicationContext.packageName
            return mockLocationApp == packageName
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }

    private fun setMockLocation(latitude: Double, longitude: Double) {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        locationManager.addTestProvider(
            LocationManager.GPS_PROVIDER,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            1,
            2
        )

        locationManager.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)

        val mockLocation = Location(LocationManager.GPS_PROVIDER)
        mockLocation.latitude = latitude
        mockLocation.longitude = longitude
        mockLocation.altitude = 3.0
        mockLocation.time = System.currentTimeMillis()
        mockLocation.accuracy = 0.01f
        mockLocation.speed = 0.01F
        mockLocation.bearing = 1F
        mockLocation.elapsedRealtimeNanos = System.nanoTime()

        mockLocation.bearingAccuracyDegrees = 0.1F
        mockLocation.verticalAccuracyMeters = 0.1F
        mockLocation.speedAccuracyMetersPerSecond = 0.01F

        locationManager.setTestProviderLocation(LocationManager.GPS_PROVIDER, mockLocation)
    }

    private fun stopMockLocation() {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val provider = LocationManager.GPS_PROVIDER

        // Disable the test provider
        locationManager.setTestProviderEnabled(provider, false)

        // Remove the test provider
        locationManager.removeTestProvider(provider)
    }
}
