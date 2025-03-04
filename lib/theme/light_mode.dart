import 'package:flutter/material.dart';

// Define the colors
const Color lightGrey = Color(0xFFF4F4F4); // Background
const Color mainGreen = Color(0xFF14AE5C); // Primary accent


ThemeData lightmode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: mainGreen,
    surface: Colors.white
  ),
);
