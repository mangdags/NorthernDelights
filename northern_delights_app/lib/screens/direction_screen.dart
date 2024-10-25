import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as gmaps;
import 'package:location/location.dart' as loc;

class DirectionsMapScreen extends StatefulWidget {
  final double destinationLong;
  final double destinationLat;
  final String destinationName;

  DirectionsMapScreen({super.key, required this.destinationLat, required this.destinationLong, required this.destinationName,});

  @override
  _DirectionsMapScreenState createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  GoogleMapController? _controller;
  final loc.Location _location = loc.Location();
  LatLng? _currentLocation; //= LatLng(17.575969808573436, 120.38716424495031); // Default location
  final _directions = gmaps.GoogleMapsDirections(apiKey: "AIzaSyCBPHgN6Rx3N_1p4HMCLMuwyAOfmvnUggQ");
  List<LatLng> _polylineCoordinates = [];
  StreamSubscription<loc.LocationData>? _locationSubscription;
  Set<Marker> _markers = {};

  @override
  void dispose() {
    _locationSubscription?.cancel(); // Cancel the location listener when disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation(); // Get current location
    _addDestinationMarker();
  }

  void _addDestinationMarker() {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: LatLng(widget.destinationLat, widget.destinationLong),
          infoWindow: InfoWindow(
            title: widget.destinationName,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
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

  // Get the user's current location
  void _getCurrentLocation() async {
    try {
      final locationData = await _location.getLocation();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          _getDirections(LatLng(widget.destinationLat, widget.destinationLong));
          _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
        });
      }

      // Listen for location changes and update _currentLocation
      _locationSubscription = _location.onLocationChanged.listen((loc.LocationData locationData) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          });
          //_controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!)); // Optional: update camera on location change
        }
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    if (_currentLocation == null) return; // Ensure _currentLocation is available

    final origin = gmaps.Location(lat: _currentLocation!.latitude, lng: _currentLocation!.longitude);
    final dest = gmaps.Location(lat: destination.latitude, lng: destination.longitude);

    // Request directions
    final directions = await _directions.directions(origin, dest);

    if (directions.isOkay && directions.routes.isNotEmpty) {
      final route = directions.routes.first;

      // Decode the polyline using the polyline string
      List<LatLng> polylinePoints = _decodePoly(route.overviewPolyline.points);

      if (mounted) {
        setState(() {
          _polylineCoordinates = polylinePoints;
        });
      }
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
      appBar: AppBar(title: Text("Directions to ${widget.destinationName}")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? LatLng(0, 0), // (0, 0) as fallback
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _controller = controller;
          if (_currentLocation != null) {
            _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
          }
        },
        myLocationEnabled: true,
        compassEnabled: true,
        zoomGesturesEnabled: true,
        markers: _markers,
        polylines: {
          if (_polylineCoordinates.isNotEmpty)
            Polyline(
              polylineId: PolylineId("directions"),
              points: _polylineCoordinates,
              color: Colors.red,
              width: 5,
            ),
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Manually center map on current location
              if (_currentLocation != null) {
                _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
              }
            },
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              // Get directions to the destination
              _getDirections(LatLng(widget.destinationLat, widget.destinationLong));
            },
            child: Icon(Icons.directions),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
