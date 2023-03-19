import 'package:share/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Otp extends StatefulWidget {
  const Otp({super.key});

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 0.8;
    double widgetWidth2 = screenWidth * 0.3;
    TextEditingController phoneController = TextEditingController();
    TextEditingController otpController = TextEditingController();

    FirebaseAuth auth = FirebaseAuth.instance;

    User? user;
    String verificationID = "";
    final FirebaseAuth _auth = FirebaseAuth.instance;
    void loginWithPhone() async {
      auth.verifyPhoneNumber(
        phoneNumber: "+91" + phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) {
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationID = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }

    void verifyOTP() async {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: otpController.text);

      await auth.signInWithCredential(credential).then(
        (value) {
          setState(() {
            user = FirebaseAuth.instance.currentUser;
          });
        },
      ).whenComplete(
        () {
          if (user != null) {
            Fluttertoast.showToast(
              msg: "You are logged in successfully",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          } else {
            Fluttertoast.showToast(
              msg: "your login is failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 50),
            child: Text(
              "File Sharing",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              "You Are Almost" + "\nThere",
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w500, height: 1.5),
            ),
          ),
          SizedBox(),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Otp',
              hintStyle: TextStyle(color: Colors.black),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
          Center(
              child: SizedBox(
                  width: widgetWidth2,
                  child: ElevatedButton(
                    onPressed: () {
                      verifyOTP();
                    },
                    child: Text(
                      "Confirm",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                  ))),
          Center(
            child: ElevatedButton(
              onPressed: null,
              child: Text(
                "Resend",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
            ),
          ),
        ],
      ),
    );
  }
}
