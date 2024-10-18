import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

List<Widget> foodPlaceWidgetList = [];
List<String> gastroPubDocID = <String>[];

class GastropubService {
  Stream<List<Map<String, dynamic>>> getGastropubData() {
    return FirebaseFirestore.instance.collection('gastropubs').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      },
    );
  }
}