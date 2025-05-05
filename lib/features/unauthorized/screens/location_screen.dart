import 'package:are_mart/features/unauthorized/controllers/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.selectedLocation.value,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('selectedLocation'),
                    position: controller.selectedLocation.value,
                    draggable: true,
                    onDragEnd: (LatLng newPosition) {
                      controller.selectedLocation.value = newPosition;
                    },
                  ),
                },
                onMapCreated: (GoogleMapController mapController) {
                  // You can store the map controller if needed
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onSubmitted: (value) {
                controller.geocodeAddress(value);
              },
              decoration: InputDecoration(
                labelText: 'Enter Address',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.getCurrentLocation();
            },
            child: Text('Use Current Location'),
          ),
        ],
      ),
    );
  }
}
