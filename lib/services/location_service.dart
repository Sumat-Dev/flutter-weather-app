import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _prefsKey = 'weather_data';

  /// Save weather data to shared preferences for the widget
  static Future<void> saveWeatherData({
    required double temp,
    required String condition,
    required String location,
    required int humidity,
    required double windSpeed,
    required double feelsLike,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Save weather data
      await prefs.setDouble('flutter.weather_temp', temp);
      await prefs.setString('flutter.weather_condition', condition);
      await prefs.setString('flutter.weather_location', location);
      await prefs.setInt('flutter.weather_humidity', humidity);
      await prefs.setDouble('flutter.weather_wind', windSpeed);
      await prefs.setDouble('flutter.weather_feels_like', feelsLike);
      await prefs.setInt('flutter.weather_last_updated', now);

      // Trigger widget update
      await _updateWidget(prefs);
    } catch (e) {
      debugPrint('Error saving weather data: $e');
    }
  }

  /// Update the widget with the latest data
  static Future<void> _updateWidget(SharedPreferences prefs) async {
    try {
      final widgetData = {
        'temp': prefs.getDouble('flutter.weather_temp'),
        'condition': prefs.getString('flutter.weather_condition'),
        'location': prefs.getString('flutter.weather_location'),
        'humidity': prefs.getInt('flutter.weather_humidity'),
        'windSpeed': prefs.getDouble('flutter.weather_wind'),
        'lastUpdated': prefs.getInt('flutter.weather_last_updated'),
      };

      // Save the widget data as a JSON string
      await prefs.setString(_prefsKey, jsonEncode(widgetData));

      // Notify the widget to update (Android only)
      if (prefs.containsKey('flutter.weather_last_updated')) {
        // This will be handled by the platform-specific code
        await prefs.setBool('flutter.weather_should_update', true);
      }
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  static Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        throw Exception("Location services are disabled (check permissions)");
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('Current permission: $permission');

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          throw Exception("Location permissions are denied");
        }
      }

      // Handle permanently denied permissions
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Location permissions are permanently denied. Please enable them in device settings.",
        );
      }

      debugPrint('Getting current position...');
      // Get current position with updated settings
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );
    } catch (e) {
      debugPrint('Location error: $e');
      rethrow;
    }
  }

  /// Clear saved weather data
  static Future<void> clearWeatherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('flutter.weather_temp');
      await prefs.remove('flutter.weather_condition');
      await prefs.remove('flutter.weather_location');
      await prefs.remove('flutter.weather_humidity');
      await prefs.remove('flutter.weather_wind');
      await prefs.remove('flutter.weather_feels_like');
      await prefs.remove('flutter.weather_last_updated');
      await prefs.remove('flutter.weather_should_update');
      await prefs.remove(_prefsKey);
    } catch (e) {
      debugPrint('Error clearing weather data: $e');
    }
  }

  /// Check if location permissions are granted
  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Open device settings for location permissions
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Get detailed permission status for debugging
  static Future<String> getPermissionStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    return 'Service enabled: $serviceEnabled, Permission: $permission';
  }

  /// Open app-specific settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
