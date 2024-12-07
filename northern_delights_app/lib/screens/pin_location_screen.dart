import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PinLocationScreen extends StatefulWidget {
  const PinLocationScreen({
    super.key,
    required this.sellerId,
    required this.storeType,
  });

  final String sellerId;
  final String storeType;

  @override
  _PinLocationScreenState createState() => _PinLocationScreenState();
}

class _PinLocationScreenState extends State<PinLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation; // Holds the pinned location
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Location'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLocationToFirestore,
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(17.575694692965204, 120.38685491878553), // Default to Capitol Vigan City
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _selectedLocation == null
            ? {}
            : {
          Marker(
            markerId: const MarkerId('pinnedLocation'),
            position: _selectedLocation!,
          ),
        },
        onTap: (LatLng position) {
          setState(() {
            _selectedLocation = position; // Update pinned location
          });
        },
      ),
    );
  }

  Future<void> _saveLocationToFirestore() async {
    if (_selectedLocation == null) return;

    try {
      await _firestore.collection(widget.storeType).doc(widget.sellerId).update({
        'geopoint': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location saved successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }
}
