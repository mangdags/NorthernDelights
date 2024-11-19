import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/restaurant_doc_data.dart';
import 'package:northern_delights_app/screens/restaurant_info_screen.dart';

class RestaurantsCard extends StatefulWidget {
  final String selectedCategory;
  final String? searchKeyword; // New optional parameter for search keyword
  final Map<String, dynamic>? data;

  const RestaurantsCard({super.key, required this.selectedCategory, this.searchKeyword, this.data});

  @override
  _RestaurantsCardState createState() => _RestaurantsCardState();
}

class _RestaurantsCardState extends State<RestaurantsCard> {
  final RestaurantService restaurantService = RestaurantService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: restaurantService.getStream(widget.selectedCategory, keyword: widget.searchKeyword),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            var restoList = snapshot.data!.map((resto) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RestaurantInfo(
                        restaurantID: resto['id'],
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0.0, 4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              resto['image_url'],
                              fit: BoxFit.cover,
                              width: 220,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 220,
                                  height: 300,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.error,
                                    size: 220,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                width: 210,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      resto['name'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                          resto['location'],
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 3),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/star.svg',
                                          height: 15,
                                          width: 15,
                                          colorFilter: ColorFilter.mode(
                                              Colors.white70, BlendMode.srcIn),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          resto['rating'].toString(),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
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
                      ],
                    ),
                  ],
                ),
              );
            }).toList();

            return SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: restoList.map((item) => Padding(
                  padding: EdgeInsets.only(right: 25.0),
                  child: item,
                )).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
