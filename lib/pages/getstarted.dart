import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share/pages/Login.dart';

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
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 20),
          child: Text(
            "File Sharing",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
          ),
        ),
        Center(
          child: SizedBox(
            width: widgetWidth,
            child: Lottie.network(
                'https://assets5.lottiefiles.com/packages/lf20_8Lqgc6uKHf.json'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Text(
            "File Sharing Has" + "\nNever Been" + "\nEasier",
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
        Center(
          child: SizedBox(
            width: widgetWidth,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text("Get Started",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 23),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 20))),
          ),
        )
      ],
    ));
  }
}
