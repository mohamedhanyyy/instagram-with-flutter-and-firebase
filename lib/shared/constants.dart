import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

double smallFont = 10;
double mediumFont = 20;
double bigFont = 25;
double largeFont = 30;



TextStyle bigTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 25}) =>
    TextStyle(fontSize: bigFont, fontWeight: FontWeight.bold, color: color);

TextStyle hugeTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 30}) =>
    TextStyle(fontSize: bigFont, fontWeight: FontWeight.bold, color: color);

TextStyle smallTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 25}) =>
    TextStyle(fontSize: smallFont, color: color);

TextStyle mediumTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 25}) =>
    TextStyle(fontSize: mediumFont, color: color);


 outlineBorder()=>OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black),
    borderRadius: BorderRadius.circular(15));