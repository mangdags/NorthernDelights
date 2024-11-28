import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';
import 'package:northern_delights_app/screens/leave_review_screen.dart';
import 'package:northern_delights_app/widgets/menu_widget.dart';
import 'package:northern_delights_app/widgets/reviews_widget.dart';

enum Tab { Overview, Menu, Review }

double? screenHeight;
double? screenWidth;

class GastropubInfo extends StatefulWidget {
  const GastropubInfo({
    required this.gastropubID,
    required this.isRegular,
    super.key,
  });

  final String gastropubID;
  final bool isRegular;

  @override
  _GastropubInfoState createState() => _GastropubInfoState();
}

class _GastropubInfoState extends State<GastropubInfo> {
  final ScrollController _scrollController = ScrollController();
  bool _showCircularButton = false;
  bool _showFullHeight = false;
  Tab selectedTab =Tab.Overview; // default tab

  double? gastroLat;
  double? gastroLong;
  String? gastroName;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showCircularButton = _scrollController.offset > 60;
      });
    });
    _incrementViewCount();
    updateAverageRating(widget.gastropubID);
  }

  void _incrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('gastropubs')
          .doc(widget.gastropubID)
          .update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e'); //for debugging only
    }
  }

  void _updateCoordinates(double lat, double long) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        gastroLat = lat;
        gastroLong = long;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('gastropubs')
                .doc(widget.gastropubID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var gastro = snapshot.data!.data() as Map<String, dynamic>;
              String gastroOverview = gastro['overview'] ?? '';
              gastroName = gastro['name'];

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    FoodPlaceInfoWidget(
                      gastroID: widget.gastropubID,
                      onLocationUpdated: _updateCoordinates, // Pass the callback
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => selectedTab = Tab.Overview),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Overview ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Overview ? 20 : 18),
                            ),
                          ),
                          child: Text('Overview'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => selectedTab = Tab.Menu),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Menu ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Menu ? 20 : 18),
                            ),
                          ),
                          child: Text('Menu'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => selectedTab = Tab.Review),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Review ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Review ? 20 : 18),
                            ),
                          ),
                          child: Text('Review'),
                        ),
                      ],
                    ),
                    if (selectedTab == Tab.Overview) _buildText(gastroOverview),
                    if (selectedTab == Tab.Menu) _menuDetails(),
                    if (selectedTab == Tab.Review) ... [
                      _reviewDetails(),
                      if(widget.isRegular) ... [
                        const SizedBox(height: 20,),

                        ElevatedButton(onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) => LeaveReviewScreen(collectionType: 'gastropubs' ,restaurantGastropubId: widget.gastropubID))),
                          child: Text('Add Review'),),
                      ],
                    ],

                    const SizedBox(height: 100),
                    //Prevent clipping
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _showCircularButton
                ? Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {
                    if (gastroLat != null && gastroLong != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectionsMapScreen(
                            destinationLat: gastroLat!,
                            destinationLong: gastroLong!,
                            destinationName: gastroName!,
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                : _buildFullWidthButton(),
          ),
        ],
      ),
    );
  }

  SizedBox _reviewDetails() {
    return SizedBox(
      child: ReviewsDetails(
          foodPlaceID: widget.gastropubID,
          foodPlaceCategory: 'gastropubs'
      ),
    );
  }


  SizedBox _menuDetails() {
    return SizedBox(
      height: 600,
      child: MenuDetails(
          foodPlaceID: widget.gastropubID,
          foodPlaceCategory: 'gastropubs'
      ),
    );
  }

  Widget _buildFullWidthButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (gastroLat != null && gastroLong != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectionsMapScreen(
                    destinationLat: gastroLat!,
                    destinationLong: gastroLong!,
                    destinationName: gastroName!,
                  ),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Direction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.navigation, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateAverageRating(String docId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final reviewsCollection = firestore
          .collection('gastropubs')
          .doc(docId)
          .collection('reviews');

      final querySnapshot = await reviewsCollection.get();

      if (querySnapshot.docs.isEmpty) {
        print('No reviews found for $docId.');
        await firestore.collection('gastropubs').doc(docId).update({'rating': 0.00});
        return;
      }

      final starRatings = querySnapshot.docs
          .map((doc) => doc['star'] as num)
          .toList();

      final averageRating = starRatings.reduce((a, b) => a + b) / starRatings.length;
      final formattedRating = double.parse(averageRating.toStringAsFixed(2));

      await firestore
          .collection('gastropubs')
          .doc(docId)
          .update({'rating': formattedRating});

    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  Widget _buildText(String gastroOverview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        gastroOverview,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}

class FoodPlaceInfoWidget extends StatelessWidget {
  const FoodPlaceInfoWidget({
    required this.gastroID,
    required this.onLocationUpdated, // Accept the callback
    super.key,
  });

  final String gastroID;
  final Function(double lat, double long) onLocationUpdated; // Callback definition

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gastropubs')
          .doc(gastroID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var gastro = snapshot.data!.data() as Map<String, dynamic>;
        screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        screenHeight = MediaQuery
            .of(context)
            .size
            .height;


        GeoPoint geoPoint = gastro['geopoint'];
        double lat = geoPoint.latitude;
        double long = geoPoint.longitude;

        // Call the callback to update the parent widget's state
        onLocationUpdated(lat, long);

        return Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Image container
              Container(
                width: screenWidth! - 40,
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0.0, 4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    gastro['image_url'],
                    fit: BoxFit.cover,
                    width: 220,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.error, // Fallback if the image can't load
                          size: 220,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                bottom: 15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      width: 330,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gastro['name'],
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/location-pin.svg',
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                      Colors.white70, BlendMode.srcIn),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  gastro['location'],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const SizedBox(width: 2),
                                SvgPicture.asset(
                                  'assets/icons/star.svg',
                                  height: 15,
                                  width: 15,
                                  colorFilter: ColorFilter.mode(
                                      Colors.white70, BlendMode.srcIn),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  gastro['rating'].toString(),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
