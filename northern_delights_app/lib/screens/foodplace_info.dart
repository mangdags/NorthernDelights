import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';

class FoodplaceInfo extends StatelessWidget {
  const FoodplaceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color for the whole screen
      body: SingleChildScrollView(
        child: Column(
          children: [
            FoodPlaceInfoWidget(
              foodInfoImage: AssetImage('assets/images/empanada.jpg'),
              foodInfoTitle: 'Empanada Ilocos',
              foodInfoLocation: 'Vigan City',
              foodInfoRating: '5',
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Define your onPressed action here
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.black), // Set text color to white
                    textStyle: WidgetStateProperty.all(
                      TextStyle(fontSize: 20), // Adjust font size as needed
                    ),
                  ),
                  child: Text('Overview'),
                ),
                //Reviews/Feedback
                TextButton(
                  onPressed: () {
                    // Define your onPressed action here
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.black45), // Set text color to white
                    textStyle: WidgetStateProperty.all(
                      TextStyle(fontSize: 18), // Adjust font size as needed
                    ),
                  ),
                  child: Text('Reviews'),
                ),
                //Details TextButton
                TextButton(
                  onPressed: () {
                    // Define your onPressed action here
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.black45), // Set text color to white
                    textStyle: WidgetStateProperty.all(
                      TextStyle(fontSize: 18), // Adjust font size as needed
                    ),
                  ),
                  child: Text('Details'),
                ),
              ],
            ),

            FoodPlaceOverview(
              foodInfoOverview:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. '
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
            ),
          ],
        ),
      ),
    );
  }
}

class FoodPlaceInfoWidget extends StatelessWidget {
  const FoodPlaceInfoWidget({
    required this.foodInfoImage,
    required this.foodInfoTitle,
    required this.foodInfoLocation,
    required this.foodInfoRating,
    super.key,
  });

  final AssetImage foodInfoImage;
  final String foodInfoTitle;
  final String foodInfoLocation;
  final String foodInfoRating;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(top: 30, left: 20, right: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Image container
          Container(
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
              child: Image(
                image: foodInfoImage,
                fit: BoxFit.cover,
                width: screenWidth - 40, // Leave space for margin
                height: 450,
              ),
            ),
          ),
          // Info box aligned to the bottom center of the image
          Container(
            padding: const EdgeInsets.all(10),
            width: 300,
            height: 95,
            margin: const EdgeInsets.only(bottom: 20), // Margin from bottom
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodInfoTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3,),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/location-pin.svg',
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(Colors.white60, BlendMode.srcIn),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      foodInfoLocation,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ), 
                SizedBox(height: 3,),   
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/heart-filled.svg', 
                      colorFilter: ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                      height: 20,
                      width: 20,  
                    ),
                    SizedBox(width: 5,),
                    Text(
                      foodInfoRating, 
                      style: TextStyle(color: Colors.white70),),
                  ],
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
              child: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(81, 154, 154, 154),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                  'assets/icons/back_2.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(Colors.white60, BlendMode.srcIn),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          //Like button
          Positioned(
            top: 20,
            right: 20,
            child: 
              GestureDetector(
                child: Container(
                    alignment: Alignment.center,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(81, 154, 154, 154),
                      borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset('assets/icons/heart-empty.svg',
                  height: 30,
                  width: 30,
                  colorFilter: ColorFilter.mode(Colors.white60, BlendMode.srcIn),
                  ),
                ),
              ),
          ),
        ],
      ),
    );
  }
}

class FoodPlaceOverview extends StatelessWidget {
  const FoodPlaceOverview({
    required this.foodInfoOverview,
    super.key,
  });

  final String foodInfoOverview;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        foodInfoOverview,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}
