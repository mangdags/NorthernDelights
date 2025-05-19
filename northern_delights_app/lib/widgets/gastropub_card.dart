import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/screens/gastropub_info_screen.dart';

class GastropubCards extends StatefulWidget {
    final String selectedCategory;

    const GastropubCards({super.key, required this.selectedCategory});

    @override
    _GastropubCardsState createState() => _GastropubCardsState();
}

class _GastropubCardsState extends State<GastropubCards> {
    final GastropubService gastropubService = GastropubService();

<<<<<<< Updated upstream
=======
    late Timestamp openingTime;
    late Timestamp closingTime;
    late TimeOfDay openTimeOfDay;
    late TimeOfDay closeTimeOfDay;
    final now = TimeOfDay.now();

    String convertToDateString(TimeOfDay? timeOfDay) {

        if (timeOfDay == null) {
            return '00:00';
        }
        final hours = timeOfDay.hourOfPeriod;
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


>>>>>>> Stashed changes
    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                StreamBuilder<List<Map<String, dynamic>>>(
                    stream: gastropubService.getStream(widget.selectedCategory),
                    builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                        }

                        var gastropubList = snapshot.data!.map((gastropub) {
<<<<<<< Updated upstream
=======
                            openingTime = gastropub['open_time'];
                            closingTime = gastropub['close_time'];

                            openTimeOfDay = convertToTimeOfDay(openingTime);
                            closeTimeOfDay = convertToTimeOfDay(closingTime);

>>>>>>> Stashed changes
                            return GestureDetector(
                                onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GastropubInfo(
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
                                                            gastropub['gastro_image_url'],
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
                                                                            gastropub['gastro_name'],
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
                                                                                    gastropub['gastro_location'],
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
                                                                                    gastropub['gastro_rating'].toString(),
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
