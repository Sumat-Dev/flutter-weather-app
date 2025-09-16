import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';
import '../services/location_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _weatherData;
  late final String apiKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    apiKey = dotenv.get('WEATHER_API_KEY');
  }

  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }

  @override
  void deactivate() {
    if (_weatherData != null) {
      final current = _weatherData!['current'] ?? {};
      final location = _weatherData!['location'] ?? {};
      final condition = current['condition']?['text'] ?? 'N/A';
      final tempC = (current['temp_c'] as num?)?.toDouble() ?? 0.0;
      final feelsLikeC = (current['feelslike_c'] as num?)?.toDouble() ?? 0.0;
      final windKph = (current['wind_kph'] as num?)?.toDouble() ?? 0.0;
      final humidity = current['humidity']?.toInt() ?? 0;
      final locationName = '${location['name']}, ${location['country']}';

      LocationService.saveWeatherData(
        temp: tempC,
        condition: condition,
        location: locationName,
        humidity: humidity,
        windSpeed: windKph,
        feelsLike: feelsLikeC,
      );
    }
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final position = await _getCurrentPosition().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );

      final url =
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}&aqi=no';

      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Weather data request timed out'),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Sumat => $data');
        if (data['error'] != null) {
          throw Exception(
            data['error']['message'] ?? 'Failed to fetch weather data',
          );
        }

        if (mounted) {
          setState(() {
            _weatherData = data;
            _error = null;
            _isLoading = false;
          });

          final current = data['current'] ?? {};
          final location = data['location'] ?? {};
          final condition = current['condition']?['text'] ?? 'N/A';
          final tempC = (current['temp_c'] as num?)?.toDouble() ?? 0.0;
          final feelsLikeC =
              (current['feelslike_c'] as num?)?.toDouble() ?? 0.0;
          final windKph = (current['wind_kph'] as num?)?.toDouble() ?? 0.0;
          final humidity = current['humidity']?.toInt() ?? 0;
          final locationName = '${location['name']}, ${location['country']}';

          await LocationService.saveWeatherData(
            temp: tempC,
            condition: condition,
            location: locationName,
            humidity: humidity,
            windSpeed: windKph,
            feelsLike: feelsLikeC,
          );
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['error']?['message'] ?? 'Failed to load weather data',
        );
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _error = 'No internet connection. Tap to retry.';
          _isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          _error = '${e.message}. Tap to retry.';
          _isLoading = false;
        });
      }
    } on PlatformException catch (_) {
      if (mounted) {
        setState(() {
          _error =
              'Location services are disabled. Please enable them and try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error =
              'Failed to load weather: ${e.toString().replaceAll('Exception: ', '')}. Tap to retry.';
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buildShimmerContainer(double width, double height) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    Widget buildLoading() {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 20),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildShimmerContainer(160, 120),
                        buildShimmerContainer(160, 120),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildShimmerContainer(160, 120),
                        buildShimmerContainer(160, 120),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildError() {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Failed to load weather data. Please try again.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: _loadWeather,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: buildLoading(),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: buildError(),
      );
    }

    final current = _weatherData?['current'] ?? {};
    final location = _weatherData?['location'] ?? {};
    final condition = current['condition']?['text'] ?? 'N/A';
    final tempC = (current['temp_c'] as num?)?.toDouble() ?? 0.0;
    final feelsLikeC = (current['feelslike_c'] as num?)?.toDouble() ?? 0.0;
    final windKph = (current['wind_kph'] as num?)?.toDouble() ?? 0.0;
    final humidity = current["humidity"]?.toInt() ?? 0;
    final lastUpdated = location["localtime"]?.toString() ?? '';

    // Format the time
    _formatDateTime(lastUpdated, timeOnly: true);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 72,
                  bottom: 32,
                  left: 32,
                  right: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location and time
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 20,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${location["name"]}, ${location["country"]}',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Updated ${_formatDateTime(lastUpdated, timeOnly: false)}',
                          style: GoogleFonts.roboto(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          onPressed: _loadWeather,
                          icon: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Main weather info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${tempC.toStringAsFixed(0)}°',
                              style: GoogleFonts.roboto(
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                height: 0.9,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Feels like ${feelsLikeC.toStringAsFixed(0)}°',
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getWeatherEmoji(condition),
                              style: const TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              condition,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Weather details section
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                delegate: SliverChildListDelegate([
                  _buildWeatherDetailCard(
                    context: context,
                    icon: Icons.air,
                    label: 'Wind',
                    value: '${windKph.toStringAsFixed(1)} km/h',
                  ),
                  _buildWeatherDetailCard(
                    context: context,
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$humidity%',
                  ),
                  _buildWeatherDetailCard(
                    context: context,
                    icon: Icons.thermostat,
                    label: 'Feels Like',
                    value: '${feelsLikeC.toStringAsFixed(1)}°C',
                  ),
                  _buildWeatherDetailCard(
                    context: context,
                    icon: Icons.visibility,
                    label: 'Visibility',
                    value:
                        '${(current['vis_km'] as num?)?.toStringAsFixed(1) ?? 'N/A'} km',
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetailCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format date and time from API
  String _formatDateTime(String timeString, {bool timeOnly = true}) {
    if (timeString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(timeString);
      if (timeOnly) {
        return DateFormat('HH:mm').format(dateTime);
      }
      return DateFormat('MMM d, y • HH:mm').format(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  // Get weather condition emoji
  String _getWeatherEmoji(String condition) {
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sun') || lowerCondition.contains('clear')) {
      return '☀️';
    } else if (lowerCondition.contains('rain') ||
        lowerCondition.contains('drizzle')) {
      return '🌧️';
    } else if (lowerCondition.contains('snow') ||
        lowerCondition.contains('sleet')) {
      return '❄️';
    } else if (lowerCondition.contains('cloud')) {
      return '☁️';
    } else if (lowerCondition.contains('thunder') ||
        lowerCondition.contains('storm')) {
      return '⛈️';
    } else if (lowerCondition.contains('fog') ||
        lowerCondition.contains('mist')) {
      return '🌫️';
    } else {
      return '🌤️';
    }
  }
}
