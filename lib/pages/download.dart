import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownload extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> fileDetails;
  const FileDownload({super.key, required this.fileDetails});

  @override
  State<FileDownload> createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    print(widget.fileDetails);
    print(widget.fileDetails["filename"]);
    print(widget.fileDetails["history"].runtimeType);
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
            print("object");
            status = await Permission.storage.request();
          }
          if (status == PermissionStatus.permanentlyDenied ||
              status == PermissionStatus.granted) {
            setState(() {
              isDownloading = true;
            });
            FTPConnect ftp = FTPConnect('192.168.0.154',
                user: 'admin', pass: 'password', port: 2121);
            await ftp.connect();
            await ftp.createFolderIfNotExist("Everything");
            File("/storage/emulated/0/Documents/${widget.fileDetails['filename']}")
                .create();
            await ftp.downloadFile(
                widget.fileDetails["docReference"],
                File(
                    "/storage/emulated/0/Documents/${widget.fileDetails['filename']}"));
            setState(() {
              isDownloading = false;
            });
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
                      padding: EdgeInsets.only(left: 20.0, top: 50),
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
              title: widget.fileDetails["history"][index]["name"],
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.fileDetails["history"][index]["image"],
                ),
              ),
              trailing: Text(widget.fileDetails["history"][index]["date"]),
            );
          }
        },
      ),
    );
  }
}
