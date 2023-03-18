import 'package:share/pages/Home.dart';
import 'package:share/pages/Otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
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

  late String _verificationId;
  Future<UserCredential?> signInWithGoogle() async {
    // Create an instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    //Triger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    //Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;
    //Create a new credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    //Sign in the user with the credentials
    final UserCredential userCredential =
        await auth.signInWithCredential(credential);
    return null;
  }

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
    String otp = _otpController.text;

    if (otp.length != 6) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid OTP.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    var credential = PhoneAuthProvider.credential(
      verificationId: _verificationId, // use stored verification ID
      smsCode: otp,
    );

    await _auth.signInWithCredential(credential);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 0.8;
    double widgetWidth2 = screenWidth * 0.3;
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
              "Beginning Of The" + "\nNew Horizon",
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
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phone Number',
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
                    onPressed: _submitPhoneNumber,
                    //() {

                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => Otp()),
                    //   );
                    // },
                    child: Text(
                      "Done",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                  ))),
          Center(
              child: SizedBox(
                  width: widgetWidth,
                  child: ElevatedButton(
                    onPressed: () async {
                      await signInWithGoogle();
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Home(),
                          ),
                        );
                      }
                    },
                    child: Text.rich(
                      TextSpan(
                          text: "Login With ",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w500),
                          children: [
                            WidgetSpan(
                                child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 2, left: 5),
                              child: Image.network(
                                  'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                                  height: 25,
                                  width: 25),
                            )),
                          ]),
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20)),
                  ))),
        ],
      ),
    );
  }
}
