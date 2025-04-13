import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';

class EstablishmentsMap extends StatefulWidget {
  @override
  _EstablishmentsMapState createState() => _EstablishmentsMapState();
}

class _EstablishmentsMapState extends State<EstablishmentsMap> {
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  late GeoPoint _sellerLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadGastropubs();
    _loadRestos();
  }

  Future<void> _loadGastropubs() async {
    final snapshot = await FirebaseFirestore.instance.collection('gastropubs').get();

    final markers = snapshot.docs.map((doc) {
      final geoPoint = doc['geopoint'] as GeoPoint;
      final name = doc['name'] ?? 'Unnamed Gastropub';
      final location = doc['location'] ?? 'Unknown Location';
      final openTime = DateFormat.jm().format((doc['open_time']).toDate());
      final closeTime = DateFormat.jm().format((doc['close_time']).toDate());
      _sellerLocation = geoPoint;

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(
          title: name,
          snippet: 'Tap for details',
          onTap: () => _showGuide(doc.id, name, location, '$openTime - $closeTime'),
        ),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
    });
  }


  Future<void> _loadRestos() async {
    final snapshot = await FirebaseFirestore.instance.collection('restaurants').get();

    final markers = snapshot.docs.map((doc) {
      final geoPoint = doc['geopoint'] as GeoPoint;
      final name = doc['name'] ?? 'Unnamed Restaurant';
      final location = doc['location'] ?? 'Unknown Location';
      final openTime = DateFormat.jm().format((doc['open_time']).toDate());
      final closeTime = DateFormat.jm().format((doc['close_time']).toDate());
      _sellerLocation = geoPoint;

      return Marker(
        markerId: MarkerId(doc.id),
        position: LatLng(geoPoint.latitude, geoPoint.longitude),
        infoWindow: InfoWindow(
          title: name,
          snippet: 'Tap for details',
          onTap: () => _showGuide(doc.id, name, location, '$openTime - $closeTime'),
        ),
      );
    }).toSet();

    setState(() {
      _markers.addAll(markers);
    });
  }

  void _showGuide(String id, String name, String location, String time) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(location),
              Text(time),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DirectionsMapScreen(
                        destinationLat: _sellerLocation.latitude,
                        destinationLong: _sellerLocation.longitude,
                        destinationName: name,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward),
                label: Text('View More'),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _getUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final userLocation = await location.getLocation();
    setState(() {
      _currentLocation = LatLng(userLocation.latitude!, userLocation.longitude!);
    });

    // Center map on user location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vigan Delights')),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation!,
          zoom: 14,
        ),
        onMapCreated: (controller) {
          _mapController = controller;
          if (_currentLocation != null) {
            _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(_currentLocation!, 14),
            );
          }
        },
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
