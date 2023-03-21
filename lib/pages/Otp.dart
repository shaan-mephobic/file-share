import 'package:share/pages/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_helper.dart';
import 'package:another_flushbar/flushbar_route.dart';

class Otp extends StatefulWidget {
  final String verID;
  const Otp({super.key, required this.verID});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  String? user;
  Future<void> verifyOTP() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verID, smsCode: otpController.text);
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      user = value.user?.uid;
      print(user);
      print("aabove");
      Navigator.of(context).pop();
    });
  }

  // Future<void> verifyOTP() async {
  //   String otp = otpController.text.trim();
  //   if (otp.isEmpty || otp.length != 6) {
  //     showToast("Please Enter a Valid The OTP");
  //     return;
  //   }

  //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //     verificationId: widget.verID,
  //     smsCode: otp,
  //   );
  //   try {
  //     UserCredential authResult =
  //         await FirebaseAuth.instance.signInWithCredential(credential);
  //     user = authResult.user?.uid;
  //     print(user);
  //   } catch (e) {
  //     showToast("Invalid OTP");
  //     return;
  //   }
  // }

  void showToast(String message) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 3),
      messageColor: Colors.white,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth2 = screenWidth * 0.3;
    double widgetWidth = screenWidth * 0.8;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30, top: 50),
            child: Text(
              "File Sharing",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              "You Are Almost" + "\nThere",
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
          const SizedBox(),
          Center(
            child: SizedBox(
              width: widgetWidth,
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black, // set border color here
                    ),
                  ),
                  hintText: 'Enter Your OTP',
                  labelText: 'Otp',
                  labelStyle: TextStyle(
                      fontWeight: FontWeight.w500, color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black, fontSize: 13),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
          Center(
              child: SizedBox(
                  width: widgetWidth,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await verifyOTP();
                        Flushbar(
                          title: "You Logged In Successfully",
                          message: "You Logged In Successfully",
                          duration: Duration(seconds: 3),
                        ).show(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                        );
                      } catch (e) {
                        Flushbar(
                          title: "your login is failed",
                          message: "your login is failed",
                          duration: Duration(seconds: 3),
                        ).show(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20)),
                    child: const Text(
                      "Confirm",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ))),
          Center(
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
              child: const Text(
                "Resend",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
