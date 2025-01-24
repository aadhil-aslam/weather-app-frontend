import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:weather_cast/services/api_service.dart';

class WeatherService {
  ApiService _apiServices = ApiService();

  Future<Map<String, dynamic>?> fetchWeather(
      {String? city, double? lat, double? lon}) async {
    String url;

    if (lat != null && lon != null) {
      url = '${_apiServices.baseUrl}weather/current?lat=$lat&lon=$lon';
    } else if (city != null && city.isNotEmpty) {
      url = '${_apiServices.baseUrl}weather/current?city=$city';
    } else {
      throw Exception('Either city or latitude/longitude must be provided.');
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch weather data: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchForecast(
      {String? city, double? lat, double? lon}) async {
    String url;

    if (lat != null && lon != null) {
      url = '${_apiServices.baseUrl}weather/forecast?lat=$lat&lon=$lon';
    } else if (city != null && city.isNotEmpty) {
      url = '${_apiServices.baseUrl}weather/forecast?city=$city';
    } else {
      throw Exception('Either city or latitude/longitude must be provided.');
    }

    final response = await http.get(Uri.parse(url));
    // print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to fetch forecast data: ${response.body}');
      return null;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      // Check and request location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Fetch user location
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error fetching location: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchWeatherForCurrentLocation() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        return await fetchWeather(
            lat: position.latitude, lon: position.longitude);
      }
      return null;
    } catch (e) {
      print('Error fetching weather for current location: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchForecastForCurrentLocation() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        return await fetchForecast(
            lat: position.latitude, lon: position.longitude);
      }
      return null;
    } catch (e) {
      print('Error fetching forecast for current location: $e');
      return null;
    }
  }
}
