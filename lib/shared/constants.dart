import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double smallFont = 10;
const double mediumFont = 20;
const double bigFont = 20;
const double largeFont = 25;



    TextStyle bigTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 19}) =>
    TextStyle(fontSize: bigFont, fontWeight: FontWeight.bold, color: color);

 TextStyle hugeTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 25}) =>
    TextStyle(fontSize: bigFont, fontWeight: FontWeight.bold, color: color);

TextStyle smallTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 15}) =>
    TextStyle(fontSize: smallFont, color: color);

TextStyle mediumTextStyle(
        {Color color = Colors.black,
        FontWeight fontWeight = FontWeight.bold,
        double fontSize = 20}) =>
    TextStyle(fontSize: mediumFont, color: color);


 outlineBorder()=>OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.black),
    borderRadius:  BorderRadius.circular(15));