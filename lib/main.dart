import 'package:flutter/material.dart';
import 'package:share/pages/home.dart';
import "pages/start.dart";
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Share',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "SpaceGroteskt"),
      home: const Getstarted(),
    );
  }
}
