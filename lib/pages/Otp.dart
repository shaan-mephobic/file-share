import 'package:share/pages/Home.dart';
import 'package:share/pages/Otp.dart';
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
    final TextEditingController _otpController = TextEditingController();
    final TextEditingController _phoneNumberController =
        TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    bool _validatePhoneNumber() {
      String phoneNumber = '+91${_phoneNumberController.text.trim()}';

      if (phoneNumber.isEmpty || phoneNumber.length != 13) {
        Fluttertoast.showToast(
          msg: 'Please enter a valid phone number.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return false;
      }

      return true;
    }

    String _verificationId = '';

    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 0.8;
    double widgetWidth2 = screenWidth * 0.3;
 // define a state variable to store verification ID

    Future<void> _submitPhoneNumber() async {
      String phoneNumber = '+91${_phoneNumberController.text.trim()}';

      if (phoneNumber.length != 13) {
        Fluttertoast.showToast(
          msg: 'Please enter a valid phone number.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      // Verify the reCAPTCHA first
      final PhoneVerificationCompleted verificationCompleted =
          (PhoneAuthCredential phoneAuthCredential) async {
        await _auth.signInWithCredential(phoneAuthCredential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Otp(),
          ),
        );
      };

      final PhoneVerificationFailed verificationFailed =
          (FirebaseAuthException authException) {
        Fluttertoast.showToast(
          msg: 'Failed to verify phone number. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      };

      final PhoneCodeSent codeSent =
          (String verificationId, int? resendToken) async {
        setState(() {
          _verificationId = verificationId; // store verification ID
        });

        // Navigate to OTP screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Otp(),
          ),
        );
      };

      final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
          (String verificationId) {
        setState(() {
          _verificationId = verificationId; // store verification ID
        });
      };

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: Duration(seconds: 60),
      );
    }

    Future<void> _submitOtp() async {
      String otp = _otpController.text.trim();

      if (otp.length != 6) {
        Fluttertoast.showToast(
          msg: 'Please enter a valid OTP.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, // use stored verification ID
        smsCode: otp,
      );

      try {
        await _auth.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } on FirebaseAuthException catch (e) {
        print(e);
        Fluttertoast.showToast(
          msg: 'Incorrect OTP. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
      }
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
          Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5), //shadow color
                      spreadRadius: 5, // spread radius
                      blurRadius: 7, // shadow blur radius
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Otp',
                    hintStyle: TextStyle(color: Colors.black),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          Center(
              child: SizedBox(
                  width: widgetWidth2,
                  child: ElevatedButton(
                    onPressed: _submitOtp,
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
