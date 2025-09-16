# Flutter Weather App

<p align="center">
  <img src="flutter_weather.png" alt="Flutter Weather App Screenshot" width="300">
</p>

A Flutter weather app that uses your device location to show current weather conditions.

## ✨ Features

- Current weather conditions
- Weather forecast
- Location-based weather data
- Beautiful and intuitive UI

## Setup

1. **Get a Weather API Key**
   - Sign up at [WeatherAPI.com](https://www.weatherapi.com/)
   - Get your free API key
   - Copy `.env.example` to `.env` and add your API key:

     ```env
     WEATHER_API_KEY="YOUR_API_KEY"
     ```

2. **Install Dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the App**

   ```bash
   flutter run
   ```

## 📦 Download APK

You can download the latest APK from the [Releases](https://github.com/Sumat-Dev/flutter-weather-app/releases) page or by clicking the button below:

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/Sumat-Dev/flutter-weather-app/releases/latest/download/app-release.apk)

### Installation

1. Download the APK file to your Android device
2. Go to Settings > Security > Enable "Install unknown apps" for your browser or file manager
3. Open the downloaded APK file and tap "Install"
4. Launch the app and grant location permissions when prompted

## 🌤️ API Used

This app uses [WeatherAPI.com](https://www.weatherapi.com/) for weather data. The free tier includes:

- 1 million calls per month
- Current weather conditions
- No credit card required
