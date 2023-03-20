import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:file_picker/file_picker.dart';
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
  String progress = "0%";
  String footer = "Click above to upload";
  bool resize = true;
  bool isDispose = false;

  @override
  void initState() {
    super.initState();
    repeatResize();
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
          resize = resize ? false : true;
        });
      }
      await Future.delayed(const Duration(milliseconds: 1600));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
                  initialValue: double.parse(
                    progress.replaceAll("%", ""),
                  ),
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
                curve: Curves.ease,
                duration: const Duration(milliseconds: 1600),
                // color: Colors.black,
                width: isUploading
                    ? screenWidth / 1.5
                    : resize
                        ? screenWidth / 1.8
                        : screenWidth / 1.5,
                height: isUploading
                    ? screenWidth / 1.5
                    : resize
                        ? screenWidth / 1.8
                        : screenWidth / 1.5,
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
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null) {
                        File file = File(result.paths.first!);
                        await widget.ftp.uploadFile(
                            sRemoteName: result.files.first.name,
                            file, onProgress: (a, b, c) async {
                          if (!isUploading) {
                            isUploading = true;
                            footer = "Uploading";
                          }
                          setState(() {
                            progress = "${a.floor()}%";
                          });
                          if (a.floor() == 100) {
                            setState(() {
                              hasUploaded = true;
                              footer = "Uploaded";
                            });
                            await Future.delayed(const Duration(seconds: 5));
                            setState(() {
                              hasUploaded = false;
                              footer = "Click above to upload";
                            });
                          }
                          // print(footer);
                        });
                        setState(() {
                          isUploading = false;
                        });
                      } else {
                        // User canceled the picker
                      }

                      // await widget.ftp.
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
