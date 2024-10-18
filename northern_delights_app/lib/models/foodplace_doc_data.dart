import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Widget> foodPlaceWidgetList = [];
List<String> gastroPubDocID = <String>[];

class GastropubDocData extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('gastropubs').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var restaurantList = snapshot.data!.docs.map((doc) {
          var gastropub = doc.data() as Map<String, dynamic>;
          return ListTile(
            leading: const Icon(Icons.restaurant),
            title: Text(gastropub['gastro_name']),
            subtitle: Text('${gastropub['gastro_location']} - Rating: ${gastropub['gastro_rating']}'),
            trailing: Text(gastropub['gastro_name']),
          );
        }).toList();

        return Container(
          height: 300,
          child: ListView(
            children: restaurantList,
          ),
        );
      },);
  }
}