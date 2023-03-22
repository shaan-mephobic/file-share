import 'package:another_flushbar/flushbar.dart';
import 'package:share/pages/home.dart';
import 'package:share/pages/Otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String _verificationId;
  Future<UserCredential?> signInWithGoogle() async {
    // Create an instance of the firebase auth and google signin
    FirebaseAuth auth = FirebaseAuth.instance;
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
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
    print("details");
    print(userCredential.additionalUserInfo!.profile);

    print("aabove");
    Navigator.of(context).pop();
    return null;
  }

  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  User? user;
  String verificationID = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = screenWidth * 0.8;
    double widgetWidth2 = screenWidth * 0.3;
    double widgetWidth3 = screenWidth * 0.5;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        foregroundColor: Colors.black,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              "Beginning Of The" + "\nNew Horizon",
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
          const SizedBox(),
          Stack(
            children: [
              Center(
                child: SizedBox(
                  width: widgetWidth,
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black, // set border color here
                        ),
                      ),
                      hintText: 'Enter Your Phone Number',
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black, fontSize: 13),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Center(
              child: SizedBox(
                  width: widgetWidth2,
                  child: ElevatedButton(
                    onPressed: () {
                      loginWithPhone();
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15)),
                    //() {

                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => Otp()),
                    //   );
                    // },
                    child: const Text(
                      "Done",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ))),
          Center(
              child: SizedBox(
                  width: widgetWidth,
                  child: ElevatedButton(
                    onPressed: () async {
                      await signInWithGoogle();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                            (Route<dynamic> route) => false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                    child: Text.rich(
                      TextSpan(
                          text: "Login With ",
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w500),
                          children: [
                            WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 2, left: 1),
                                  child: Image.network(
                                      'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                                      height: 32,
                                      width: 32),
                                )),
                          ]),
                    ),
                  ))),
        ],
      ),
    );
  }

//   void loginWithPhone() async {
//     auth.verifyPhoneNumber(
//       phoneNumber: "+91" + phoneController.text,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await auth.signInWithCredential(credential).then((value) {
//           print("You are logged in successfully");
//         });
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         print(e.message);
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         verificationID = verificationId;
//         setState(() {});
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => Otp(
//               verID: verificationID,
//             ),
//           ),
//         );
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {},
//     );
//   }
// }
  Future loginWithPhone() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      showToast("Please Enter a Valid Phone Number");
      return;
    }

    // showDialog(
    //     context: context,
    //     builder: (context) {
    //       return Center(child: CircularProgressIndicator());
    //     });
    auth.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) {
          print("You are logged in successfully");
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        showToast(e.message ?? "Verification failed");
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationID = verificationId;
        setState(() {});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Otp(
              verID: verificationID,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void showToast(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      messageColor: Colors.white,
    ).show(context);
  }
}
