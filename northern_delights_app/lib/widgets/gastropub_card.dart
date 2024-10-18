import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/screens/gastropub_info_screen.dart';
import 'package:firebase_core/firebase_core.dart';

class GastropubCards extends StatelessWidget {
    GastropubCards({
        super.key,
    });

    final GastropubService gastropubService = GastropubService();

    @override
    Widget build(BuildContext context) {
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('gastropubs').snapshots(),
            builder: (context, snapshot) {
                if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                }

                var gastropubList = snapshot.data!.docs.map((doc) {
                    var gastropub = doc.data() as Map<String, dynamic>; // Access data
                    String gastropubID = doc.id; // Doc ID

                    return GestureDetector(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Stack(
                                  children: [
                                      // Image container
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(20)), // Rounded edges for the container
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
                                              borderRadius: BorderRadius.circular(20), // Rounded corners for the image
                                              child: Image.network(
                                                  gastropub['gastro_image_url'], // Use the image URL from Firestore
                                                  fit: BoxFit.cover,
                                                  width: 220,
                                                  height: 300,
                                                  errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                          width: 220,
                                                          height: 300,
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
                                      // Box overlay on the image
                                      Positioned(
                                          bottom: 10, // Position from the bottom
                                          left: 5, // Position from the left
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                                  child: Container(
                                                  padding: const EdgeInsets.all(10), // Padding inside the box
                                                  width: 210,
                                                  height: 90,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.3), // Semi-transparent background
                                                      borderRadius: BorderRadius.circular(10), // Rounded corners for the box

                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                          Text(
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                              gastropub['gastro_name'],
                                                              style: const TextStyle(
                                                                  color: Colors.white, // Text color
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                              ),
                                                          ),
                                                          Row(
                                                              children: [
                                                                  SvgPicture.asset(
                                                                      'assets/icons/location-pin.svg',
                                                                      height: 20, // Adjust height as needed
                                                                      width: 20, // Adjust width as needed
                                                                      colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                                                                  ),
                                                                  const SizedBox(width: 5),
                                                                  Text(
                                                                      gastropub['gastro_location'], // Use location data from snapshot
                                                                      style: const TextStyle(
                                                                          color: Colors.white70,
                                                                          fontSize: 12,
                                                                      ),
                                                                  ),
                                                              ],
                                                          ),
                                                          const SizedBox(height: 3,),
                                                          Row(
                                                              children: [
                                                                  const SizedBox(width: 2),
                                                                  SvgPicture.asset(
                                                                      'assets/icons/star.svg',
                                                                      height: 15,
                                                                      width: 15,
                                                                      colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Text(
                                                                      gastropub['gastro_rating'].toString(),
                                                                      style: const TextStyle(
                                                                          color: Colors.white70,
                                                                          fontSize: 12,
                                                                      ),
                                                                  ),
                                                              ],
                                                          )
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
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GastropubInfo(gastropubID: gastropubID,)));
                        },
                    );
                }).toList();

                return SizedBox(
                    height: 400,
                    child: ListView(
                        scrollDirection: Axis.horizontal, // Horizontal scrolling
                        children: gastropubList.map((item) => Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: item,
                        )).toList(),
                    ),
                );

            },
        );
    }
}
