import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/screens/gastropub_info_screen.dart';

class GastropubCards extends StatefulWidget {
    @override
    _GastropubCardsState createState() => _GastropubCardsState();
}

class _GastropubCardsState extends State<GastropubCards> {
    final GastropubService gastropubService = GastropubService();
    String _filter = 'allUnsorted'; // Default filter

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                // Buttons to switch between filters
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton(
                            onPressed: () {
                                setState(() {
                                    _filter = 'allUnsorted';
                                });
                            },
                            child: Text('Unsorted'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                            onPressed: () {
                                setState(() {
                                    _filter = 'mostViewed';
                                });
                            },
                            child: Text('Most Viewed'),
                        ),
                    ],
                ),
                SizedBox(height: 16),

                // StreamBuilder to dynamically fetch data
                StreamBuilder<List<Map<String, dynamic>>>(
                    stream: gastropubService.getStream(_filter),
                    builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                        }

                        var gastropubList = snapshot.data!.map((gastropub) {
                            return GestureDetector(
                                onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GastropubInfo(
                                                gastropubID: gastropub['id'], // Pass the document ID
                                            ),
                                        ),
                                    );
                                },
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        Stack(
                                            children: [
                                                // Image container
                                                Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: const BorderRadius.all(
                                                            Radius.circular(20)), // Rounded edges
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
                                                            gastropub['gastro_image_url'],
                                                            fit: BoxFit.cover,
                                                            width: 220,
                                                            height: 300,
                                                            errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                    width: 220,
                                                                    height: 300,
                                                                    alignment: Alignment.center,
                                                                    child: const Icon(
                                                                        Icons.error,
                                                                        size: 220,
                                                                        color: Colors.red,
                                                                    ),
                                                                );
                                                            },
                                                        ),
                                                    ),
                                                ),
                                                // Overlay box with information
                                                Positioned(
                                                    bottom: 10,
                                                    left: 5,
                                                    child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: BackdropFilter(
                                                            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                                            child: Container(
                                                                padding: const EdgeInsets.all(10),
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
                                                                            gastropub['gastro_name'],
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            style: const TextStyle(
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
                                                                                    colorFilter: const ColorFilter.mode(
                                                                                        Colors.white70, BlendMode.srcIn),
                                                                                ),
                                                                                const SizedBox(width: 5),
                                                                                Text(
                                                                                    gastropub['gastro_location'],
                                                                                    style: const TextStyle(
                                                                                        color: Colors.white70,
                                                                                        fontSize: 12,
                                                                                    ),
                                                                                ),
                                                                            ],
                                                                        ),
                                                                        const SizedBox(height: 3),
                                                                        Row(
                                                                            children: [
                                                                                SvgPicture.asset(
                                                                                    'assets/icons/star.svg',
                                                                                    height: 15,
                                                                                    width: 15,
                                                                                    colorFilter: const ColorFilter.mode(
                                                                                        Colors.white70, BlendMode.srcIn),
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
                            );
                        }).toList();

                        return SizedBox(
                            height: 400,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: gastropubList.map((item) => Padding(
                                    padding: const EdgeInsets.only(right: 25.0),
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
