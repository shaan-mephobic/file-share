import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:share/constant/constants.dart';
import 'package:share/logic/firebase_db.dart';
import 'package:share/logic/hive_db.dart';
import 'package:share/widgets/file_clip.dart';

class FileDownload extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> fileDetails;
  const FileDownload({super.key, required this.fileDetails});

  @override
  State<FileDownload> createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  bool isDownloading = false;
  String progress = "-1";

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.transparent,
        icon: isDownloading
            ? null
            : const Icon(Icons.create_new_folder_outlined, color: Colors.black),
        label: isDownloading
            ? progress == "-1"
                ? Center(
                    child: SizedBox(
                      height: screenWidth / 25,
                      width: screenWidth / 25,
                      child: const CircularProgressIndicator(
                        strokeWidth: 3,
                        backgroundColor: Colors.transparent,
                        color: Colors.black,
                      ),
                    ),
                  )
                : Text(
                    progress,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black),
                  )
            : const Text("Download",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
        // backgroundColor: const Color(0xFF1DB954),
        backgroundColor: Colors.white,
        elevation: 8.0,
        onPressed: () async {
          late PermissionStatus status;
          if (!await Permission.storage.isGranted) {
            status = await Permission.storage.request();
          }
          if (status == PermissionStatus.permanentlyDenied ||
              status == PermissionStatus.granted) {
            setState(() {
              isDownloading = true;
            });

            DateTime now = DateTime.now();
            DateFormat formatter = DateFormat('dd-MM-yyyy');
            String formattedDate = formatter.format(now);

            List history = widget.fileDetails['history'];
            history.insert(0, {
              "name": box.get("userProfile")["name"],
              "image": box.get("userProfile")["picture"],
              "date": formattedDate
            });

            await FirebaseStuffs()
                .updateHistory(widget.fileDetails["docReference"], history);

            FTPConnect ftp = FTPConnect(Constants.ipAddress,
                user: 'admin', pass: 'password', port: 2121);
            await ftp.connect();
            await ftp.createFolderIfNotExist("Everything");
            File("/storage/emulated/0/Documents/${widget.fileDetails['filename']}")
                .create();
            await ftp.downloadFile(
                widget.fileDetails["docReference"],
                File(
                    "/storage/emulated/0/Documents/${widget.fileDetails['filename']}"),
                onProgress: (a, b, c) {
              setState(() {
                progress = "${a.floor()}%";
              });
            });

            setState(() {
              isDownloading = false;
              progress = "-1";
            });
            // ignore: use_build_context_synchronously
            Flushbar(
              message: "File saved in Documents/",
              duration: const Duration(seconds: 3),
              messageColor: Colors.white,
            ).show(context);
          }
        },
      ),
      appBar: AppBar(
        foregroundColor: Colors.black,
        toolbarHeight: screenHeight / 7,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.fileDetails['filename'],
          style: const TextStyle(
              fontSize: 26, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.fileDetails["history"].length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                Hero(
                    tag: widget.fileDetails["docReference"],
                    child: Center(
                      child: SizedBox(
                        width: screenWidth / 2,
                        child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              //shadow
                              Transform.translate(
                                offset: const Offset(0, 2),
                                child: ImageFiltered(
                                  imageFilter:
                                      ImageFilter.blur(sigmaY: 4, sigmaX: 4),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.transparent,
                                        width: 0,
                                      ),
                                    ),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.18),
                                          BlendMode.srcATop),
                                      child: SvgPicture.asset(
                                        "assets/files/file.svg",
                                        fit: BoxFit.contain,
                                        width: screenWidth / 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // svg
                              SvgPicture.asset(
                                "assets/files/file.svg",
                                fit: BoxFit.contain,
                                width: screenWidth / 2,
                              ),
                            ]),
                      ),
                    )),
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 2))
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                              widget.fileDetails["uploaderImage"],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(widget.fileDetails['uploader'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 25)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(left: 20.0, top: 50, bottom: 40),
                      child: Text("Transactions",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 23)),
                    )
                  ],
                )
              ],
            );
          } else {
            return ListTile(
              tileColor: (index - 1) % 2 != 0 ? Colors.white : Colors.grey[300],
              title: Text(widget.fileDetails["history"][index - 1]["name"],
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              leading: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 2,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.fileDetails["history"][index - 1]["image"],
                  ),
                ),
              ),
              trailing: Text(widget.fileDetails["history"][index - 1]["date"]),
            );
          }
        },
      ),
    );
  }
}
