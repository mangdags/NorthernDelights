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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
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
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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

    //center map on user location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.place, color: color, size: 20),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13)),
      ],
    );
  }

  void _searchEstablishment(String query) {
    final foundMarker = _markers.firstWhere(
          (marker) => marker.infoWindow.title!.toLowerCase().contains(query.toLowerCase()),
      orElse: () => Marker(markerId: MarkerId('not_found')),
    );

    if (foundMarker.markerId.value != 'not_found') {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(foundMarker.position),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vigan Delights')),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          //gmap as the background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentLocation!, 14),
                );
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false, //hides the default share/directions icons
            ),
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                onChanged: _searchEstablishment,
                decoration: InputDecoration(
                  hintText: 'Search establishments...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                ),
              ),
            ),
          ),

          //legend at the bottom left
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Store Legend',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  _legendItem(Colors.red, 'Gastropubs'),
                  SizedBox(height: 4),
                  _legendItem(Colors.blue, 'Restaurants'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
