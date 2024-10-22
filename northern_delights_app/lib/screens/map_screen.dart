import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  final CameraPosition _initialLocation = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Example location: San Francisco
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Maps Integration")),
      body: GoogleMap(
        initialCameraPosition: _initialLocation,
        onMapCreated: (controller) {
          _controller = controller;
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        compassEnabled: true,
        zoomGesturesEnabled: true,
      ),
    );
  }
}
