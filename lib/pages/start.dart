import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share/pages/login.dart';

class Getstarted extends StatefulWidget {
  const Getstarted({super.key});

  @override
  State<Getstarted> createState() => _GetstartedState();
}

class _GetstartedState extends State<Getstarted> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 0.8;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: screenHeight / 7,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "File Sharing",
            style: TextStyle(
                fontSize: 33, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 100),
                width: widgetWidth,
                // color: Colors.red[400],
                height: screenHeight / 2,
                child: Lottie.asset(
                    'assets/files/104011-files-transfer-sharing.json',
                    fit: BoxFit.contain),
              ),
            ),
            Center(
              child: SizedBox(
                width: widgetWidth,
                child: const Text(
                  "File Sharing Has\nNever Been\nEasier",
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: widgetWidth,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text(
                      "Get Started",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 23),
                    )),
              ),
            )
          ],
        ));
  }
}
