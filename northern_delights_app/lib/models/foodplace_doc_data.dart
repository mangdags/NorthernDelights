import 'package:flutter/material.dart';

List<Widget> foodPlaceWidgetList = [];

class FoodPlaceDocs extends ChangeNotifier {
  
  addFoodPlaceIDToList() async{
    //Get the list of food place from collection here
    //var foodPlace = 

    //await 
  }
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}