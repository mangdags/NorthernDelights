import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as gmaps;
import 'package:location/location.dart' as loc;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsMapScreen extends StatefulWidget {
  final double destinationLong;
  final double destinationLat;

  DirectionsMapScreen({required this.destinationLat, required this.destinationLong});

  @override
  _DirectionsMapScreenState createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  GoogleMapController? _controller;
  loc.Location _location = loc.Location();
  LatLng _currentLocation = LatLng(37.7749, -122.4194); // Default location
  final _directions = gmaps.GoogleMapsDirections(apiKey: "AIzaSyCBPHgN6Rx3N_1p4HMCLMuwyAOfmvnUggQ");
  List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _location.onLocationChanged.listen((loc.LocationData locationData) {
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation));
      });
    });

    _getDirections(LatLng(widget.destinationLat, widget.destinationLong));
  }

  // Request location permissions
  void _checkPermissions() async {
    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) return;
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    final origin = gmaps.Location(lat: _currentLocation.latitude, lng: _currentLocation.longitude);
    final dest = gmaps.Location(lat: destination.latitude, lng: destination.longitude);

    // Request directions
    final directions = await _directions.directions(origin, dest);

    if (directions.isOkay && directions.routes.isNotEmpty) {
      final route = directions.routes.first;

      // Decode the polyline using the polyline string
      List<LatLng> polylinePoints = _decodePoly(route.overviewPolyline.points);

      setState(() {
        _polylineCoordinates = polylinePoints;
      });
    } else {
      print('Error fetching directions: ${directions.errorMessage}');
    }
  }

  // Method to decode polyline string to LatLng points
  List<LatLng> _decodePoly(String poly) {
    var list = poly.codeUnits;
    List<LatLng> coordinates = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = list[index++] - 63; // Convert to base64
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result >> 1) ^ (~(result & 1) + 1); // Zigzag decoding
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = list[index++] - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result >> 1) ^ (~(result & 1) + 1);
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return coordinates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Directions to Restaurant")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _controller = controller;
          _location.getLocation().then((locationData) {
            _controller?.animateCamera(CameraUpdate.newLatLng(
              LatLng(locationData.latitude!, locationData.longitude!),
            ));
          });
        },
        myLocationEnabled: true,
        compassEnabled: true,
        zoomGesturesEnabled: true,
        polylines: {
          if (_polylineCoordinates.isNotEmpty)
            Polyline(
              polylineId: PolylineId("directions"),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example destination: Restaurant at LatLng(37.7849, -122.4294)
          _getDirections(LatLng(37.7849, -122.4294));
        },
        child: Icon(Icons.directions),
      ),
    );
  }
}
