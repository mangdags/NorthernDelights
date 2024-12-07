import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
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

    late Timestamp openingTime;
    late Timestamp closingTime;
    late TimeOfDay openTimeOfDay;
    late TimeOfDay closeTimeOfDay;
    final now = TimeOfDay.now();

    String convertToDateString(TimeOfDay? timeOfDay) {

        if (timeOfDay == null) {
            return '00:00';
        }
        final hours = timeOfDay.hourOfPeriod; // Gets the hour in 12-hour format
        final minutes = timeOfDay.minute;
        final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

        return '$hours:${minutes.toString().padLeft(2, '0')} $period';
    }

    TimeOfDay convertToTimeOfDay(Timestamp timestamp) {
        final dateTime = timestamp.toDate();
        return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    }

    bool isStoreClosed(TimeOfDay open, TimeOfDay close, TimeOfDay now) {
        final currentMinutes = now.hour * 60 + now.minute;
        final openMinutes = open.hour * 60 + open.minute;
        final closeMinutes = close.hour * 60 + close.minute;

        if (closeMinutes > openMinutes) {
            return !(currentMinutes >= openMinutes && currentMinutes < closeMinutes);
        } else {
            return !(currentMinutes >= openMinutes || currentMinutes < closeMinutes);
        }
    }


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
                            openingTime = gastropub['open_time'];
                            closingTime = gastropub['close_time'];

                            openTimeOfDay = convertToTimeOfDay(openingTime);
                            closeTimeOfDay = convertToTimeOfDay(closingTime);

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

                                                if (isStoreClosed(openTimeOfDay, closeTimeOfDay, now))...[

                                                    Positioned.fill(
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors.black.withOpacity(0.6),
                                                                borderRadius: BorderRadius.circular(20),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                                    'Closed',
                                                                    style: TextStyle(
                                                                        color: Colors.white,
                                                                        fontSize: 24,
                                                                        fontWeight: FontWeight.bold,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ],


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
                                                                height: 110,
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
                                                                                    height: 15,
                                                                                    width: 15,
                                                                                    colorFilter: ColorFilter.mode(
                                                                                        Colors.white70, BlendMode.srcIn),
                                                                                ),
                                                                                SizedBox(width: 8),
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
                                                                        SizedBox(height: 3),
                                                                        Row(
                                                                            children: [
                                                                                Icon(Icons.access_time_outlined, color: Colors.white70,size: 16),

                                                                                SizedBox(width: 8),
                                                                                Text(
                                                                                    convertToDateString(openTimeOfDay),
                                                                                    style: TextStyle(
                                                                                        color: Colors.white70,
                                                                                        fontSize: 12,
                                                                                    ),
                                                                                ),
                                                                                SizedBox(width: 4),
                                                                                Text(
                                                                                    '-',
                                                                                    style: TextStyle(
                                                                                        color: Colors.white70,
                                                                                        fontSize: 12,
                                                                                    ),
                                                                                ),
                                                                                SizedBox(width: 4),
                                                                                Text(
                                                                                    convertToDateString(closeTimeOfDay),
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
