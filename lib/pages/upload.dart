import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share/constant/constants.dart';
import 'package:share/logic/firebase_db.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class Upload extends StatefulWidget {
  final FTPConnect ftp;
  const Upload({super.key, required this.ftp});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> with TickerProviderStateMixin {
  bool isUploading = false;
  bool hasUploaded = false;
  String progress = "-1";
  String footer = "Click above to upload";
  bool isDispose = false;
  late double screenHeight;
  late double screenWidth;
  double? wiggly;
  static const frequency = 1800;
  Map userDetails = {
    "given_name": "Shaan",
    "locale": "en",
    "family_name": "Faydh",
    "picture":
        "https://lh3.googleusercontent.com/a/AGNmyxabmd2wOA-sjH_tOVSZcduJx9b_gSWXfpKjmKLi=s96-c",
    "aud":
        "825136703376-i0oghv9t12p6klkv5j5ke9aao3ppo11o.apps.googleusercontent.com",
    "azp":
        "825136703376-b2t3tmlhv06j76rps5qd9q6a2br889vn.apps.googleusercontent.com",
    "exp": "1679373689",
    "iat": "1679370089",
    "iss": "https://accounts.google.com",
    "sub": "107178732979814569623",
    "name": "Shaan Faydh",
    "email": "chicken1010faydh@gmail.com",
    "email_verified": "true"
  };

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      repeatResize();
    });
  }

  @override
  void dispose() {
    super.dispose();
    isDispose = true;
  }

  Future<void> repeatResize() async {
    while (true) {
      if (!isDispose) {
        setState(() {
          wiggly = wiggly == screenWidth / 1.5
              ? screenWidth / 1.8
              : screenWidth / 1.5;
        });
        await Future.delayed(const Duration(milliseconds: frequency));
      } else {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    wiggly ??= screenWidth / 1.8;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: screenHeight / 7,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Padding(
            padding: EdgeInsets.only(top: screenHeight / 15),
            child: const Text(
              "NO LIMIT\nUPLOADS",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: SleekCircularSlider(
                  max: 100,
                  min: 0,
                  initialValue: progress != "-1"
                      ? double.parse(progress.replaceAll("%", ""))
                      : 0,
                  // 360,
                  innerWidget: (a) {
                    // print("intini $progress");
                    return const SizedBox();
                  },
                  appearance: CircularSliderAppearance(
                    startAngle: 270,
                    customWidths: CustomSliderWidths(
                        trackWidth: 0,
                        progressBarWidth: 15,
                        shadowWidth: 0,
                        handlerSize: 0),
                    customColors: CustomSliderColors(
                        shadowColor: Colors.white,
                        progressBarColor:
                            isUploading ? Colors.black : Colors.transparent,
                        trackColor: Colors.transparent),
                    angleRange: 360,
                    size: screenWidth / 1.5 + 25,
                  ),
                ),
              ),
              AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: frequency),
                width: isUploading ? screenWidth / 1.5 : wiggly,
                height: isUploading ? screenWidth / 1.5 : wiggly,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUploading ? Colors.white : Colors.black,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 13,
                          offset: Offset(0, 7))
                    ]),
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    enableFeedback: true,
                    highlightColor: Colors.red[400],
                    hoverColor: Colors.red[400],
                    splashColor: Colors.red[400],
                    borderRadius: BorderRadius.all(
                        Radius.circular((screenWidth / 1.5) / 2)),
                    onTap: () async {
                      //pick file
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      setState(() {
                        if (!isUploading) {
                          progress = "0%";
                          isUploading = true;
                          footer = "Uploading";
                        }
                      });
                      //connect
                      FTPConnect ftp = FTPConnect(Constants.ipAddress,
                          user: 'admin', pass: 'password', port: 2121);
                      await ftp.connect();
                      await ftp.createFolderIfNotExist("Everything");

                      if (result != null) {
                        //use random generated by id by firebase as filename
                        String uFileName =
                            await FirebaseStuffs().generateDocID();

                        //upload details of uploader
                        await FirebaseStuffs().uploadFile(
                          filename: result.files.first.name,
                          uploader: userDetails["name"],
                          uploaderImage: userDetails["picture"],
                          docReference: uFileName,
                          time: DateTime.now().millisecondsSinceEpoch,
                          fileSize:
                              "${(result.files.first.size / (1024 * 1024)).round()}MB",
                        );

                        File file = File(result.paths.first!);
                        await ftp.uploadFile(sRemoteName: uFileName, file,
                            onProgress: (a, b, c) async {
                          setState(() {
                            progress = "${a.floor()}%";
                          });
                          if (a.floor() == 100) {
                            setState(() {
                              hasUploaded = true;
                              footer = "Uploaded";
                            });
                            await Future.delayed(const Duration(seconds: 5));
                            if (!isDispose) {
                              setState(() {
                                hasUploaded = false;
                                footer = "Click above to upload";
                                progress = "-1";
                              });
                            }
                          }
                          // print(footer);
                        });
                        setState(() {
                          isUploading = false;
                        });
                        await ftp.disconnect();
                      }
                    },
                    child: Center(
                      child: Text(
                        isUploading ? progress : "Z",
                        style: TextStyle(
                            fontSize: isUploading
                                ? screenWidth / 4.2
                                : screenWidth / 2.8,
                            color: isUploading ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // AnimatedSwitcher(
          //   duration: const Duration(milliseconds: 200),
          //   transitionBuilder: (Widget child, Animation<double> animation) {
          //     return FadeTransition(
          //       // position: Tween<Offset>(
          //       //         begin: Offset(0.0, -0.5), end: Offset(0.0, 0.0))
          //       //     .animate(animation),
          //       opacity: CurvedAnimation(
          //         parent: AnimationController(
          //           duration: const Duration(milliseconds: 1700),
          //           vsync: this,
          //         )..repeat(reverse: true),
          //         curve: Curves.easeIn,
          //       ),
          //       child: child,
          //     );
          //   },
          //   child: Text(
          //     footer,
          //     key: ValueKey<String>(footer),
          //     style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
          //   ),
          // ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              footer,
              key: ValueKey<String>(footer),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}
