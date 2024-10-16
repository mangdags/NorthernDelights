import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/pages/foodplace_info.dart';

class FoodPlaceCards extends StatelessWidget {
  const FoodPlaceCards({
    required this.foodCardImage,
    required this.foodCardTitle,
    required this.foodCardLocation,
    super.key,
  });

  final AssetImage foodCardImage; //Image
  final String foodCardTitle; //Title
  final String foodCardLocation; //Title

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              // Image container
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)), // Rounded edges for the container
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
                  child: Image(
                    image: foodCardImage,
                    fit: BoxFit.cover,
                    width: 220,
                    height: 300,
                  ),
                ),
              ),
              // Box overlay on the image
              Positioned(
                bottom: 10, // Position from the bottom
                left: 10, // Position from the left
                child: Container(
                  padding: const EdgeInsets.all(10), // Padding inside the box
                  width: 200,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Semi-transparent background
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the box
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodCardTitle, // Text inside the box
                        style: TextStyle(
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
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            foodCardLocation,
                            style: TextStyle(
                              color: Colors.white54,

                            ),
                          ),
                        ],
                      )
                      
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodplaceInfo())
        );
      }, //Set the 
    );
  }
}
