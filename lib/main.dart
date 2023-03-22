import 'package:flutter/material.dart';
import 'package:share/logic/hive_db.dart';
import 'package:share/pages/home.dart';
import "pages/start.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  box = await Hive.openBox('profileBox');
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
      // theme: ThemeData(fontFamily: "SpaceGroteskt"),
      theme: ThemeData(
        fontFamily: "SpaceGroteskt",
        primaryColor: Colors.white,
        brightness: Brightness.light,
        dividerColor: Colors.white54,
        primarySwatch: Colors.red,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
        scaffoldBackgroundColor: Colors.white,
        scrollbarTheme: ScrollbarThemeData(
          interactive: true,
          thumbVisibility: const MaterialStatePropertyAll(false),
          radius: const Radius.circular(50),
          thickness: MaterialStateProperty.all(4),
          crossAxisMargin: 2,
          thumbColor: MaterialStateProperty.all(Colors.white30),
        ),
      ),
      home: box.get("userProfile") == null ? const Getstarted() : const Home(),
    );
  }
}
