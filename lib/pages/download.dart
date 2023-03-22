import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:share/logic/firebase_db.dart';

class FileDownload extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> fileDetails;
  const FileDownload({super.key, required this.fileDetails});

  @override
  State<FileDownload> createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
//TODO replace with downloaders data

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
              "name": userDetails["name"],
              "image": userDetails["picture"],
              "date": formattedDate
            });

            await FirebaseStuffs()
                .updateHistory(widget.fileDetails["docReference"], history);

            FTPConnect ftp = FTPConnect('192.168.0.154',
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
                    child: AspectRatio(
                      aspectRatio: 1 / 1,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6),
                            ],
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )),
                ),
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