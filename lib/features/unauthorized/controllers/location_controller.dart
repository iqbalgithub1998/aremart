import 'package:are_mart/utils/logging/logger.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationController extends GetxController {
  var currentLocation = LatLng(0, 0).obs;
  var selectedLocation = LatLng(22.7246, 88.3436).obs;
  var address = ''.obs;

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition();
    currentLocation.value = LatLng(position.latitude, position.longitude);
    selectedLocation.value = currentLocation.value;
  }

  Future<void> geocodeAddress(String address) async {
    TLoggerHelper.customPrint(address);
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=AIzaSyBHkuYp8EatbQVZbKu1kuLRR3V0C_IbHvk',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      TLoggerHelper.customPrint(data);
      if (data['status'] == 'OK') {
        final location = data['results'][0]['geometry']['location'];
        selectedLocation.value = LatLng(location['lat'], location['lng']);
      }
    }
  }
}
