import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as gmaps;
import 'package:location/location.dart' as loc;

class DirectionsMapScreen extends StatefulWidget {
  final double destinationLong;
  final double destinationLat;
  final String destinationName;

  const DirectionsMapScreen({
    super.key,
    required this.destinationLat,
    required this.destinationLong,
    required this.destinationName,
  });

  @override
  _DirectionsMapScreenState createState() => _DirectionsMapScreenState();
}

class _DirectionsMapScreenState extends State<DirectionsMapScreen> {
  GoogleMapController? _controller;
  final loc.Location _location = loc.Location();
  LatLng? _currentLocation;
  final _directions = gmaps.GoogleMapsDirections(apiKey: "AIzaSyCBPHgN6Rx3N_1p4HMCLMuwyAOfmvnUggQ");
  List<LatLng> _polylineCoordinates = [];
  StreamSubscription<loc.LocationData>? _locationSubscription;
  final Set<Marker> _markers = {};

  @override
  void dispose() {
    _locationSubscription?.cancel(); // Cancel location listener when disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _getCurrentLocation(); // Get current location
    _addDestinationMarker();
    _initializeLocation();
  }

  void _initializeLocation() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      if (mounted && _controller != null) {
        final newLocation = LatLng(locationData.latitude!, locationData.longitude!);
        if (_currentLocation == null || _currentLocation != newLocation) {
          setState(() {
            _currentLocation = newLocation;
          });
        }
      }
    });
  }

  void _addDestinationMarker() {
    if((widget.destinationLat != null && widget.destinationLong != null)){
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
  }

  void _checkPermissions() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }
  }

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

      _locationSubscription = _location.onLocationChanged.listen((loc.LocationData locationData) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
          });
          //_controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!)); // Optional: update camera on location change
        }
      });
    } catch (e) {
      print('Error getting location: $e'); // For debugging only
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    try {
      if (_currentLocation == null) return;
      final origin = gmaps.Location(lat: _currentLocation!.latitude, lng: _currentLocation!.longitude);
      final dest = gmaps.Location(lat: destination.latitude, lng: destination.longitude);

      final directions = await _directions.directions(origin, dest);

      if (directions.isOkay && directions.routes.isNotEmpty) {
        final route = directions.routes.first;
        final polylinePoints = _decodePoly(route.overviewPolyline.points);

        if (mounted) {
          setState(() {
            _polylineCoordinates = polylinePoints;
          });
        }
      } else {
        print('Directions API error: ${directions.errorMessage}');
      }
    } catch (e) {
      print('Error fetching directions: $e');
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
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 18,
        ),
        onMapCreated: (controller) {
          _controller = controller;
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
              if (_currentLocation != null) {
                _controller?.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
              }
            },
            child: Icon(Icons.my_location),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
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
