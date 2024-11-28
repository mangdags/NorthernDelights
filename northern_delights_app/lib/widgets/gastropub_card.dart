import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/screens/gastropub_info_screen.dart';

class GastropubCards extends StatefulWidget {
    final String selectedCategory;
    final bool isRegular;

    const GastropubCards({super.key, required this.selectedCategory, required this.isRegular});

    @override
    _GastropubCardsState createState() => _GastropubCardsState();
}

class _GastropubCardsState extends State<GastropubCards> {
    final GastropubService gastropubService = GastropubService();

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                StreamBuilder<List<Map<String, dynamic>>>(
                    // Update the stream based on the selected category
                    stream: gastropubService.getStream(widget.selectedCategory),
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
                                                isRegular: widget.isRegular,
                                                gastropubID: gastropub['id'],

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
                                                            gastropub['image_url'],
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
                                                                            gastropub['name'],
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
                                                                                    gastropub['location'],
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
                                                                                    gastropub['rating'].toString(),
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
                                children: gastropubList.map((item) => Padding(
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
