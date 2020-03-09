import 'package:flutter/material.dart';
import 'package:flutter_firebase_face_detector/FaceDetector.dart';

void main() => runApp(MaterialApp(
  title: "Face Detector",
  darkTheme: ThemeData.dark(),
  debugShowCheckedModeBanner: false,
  home: FaceDetector(),
  themeMode: ThemeMode.dark,
));