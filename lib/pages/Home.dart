import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:share/pages/upload.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FTPConnect ftp =
      FTPConnect('192.168.0.153', user: 'admin', pass: 'password', port: 2121);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeFTP();
  }

  Future<void> initializeFTP() async {
    await ftp.connect();
    print("connected");
    await ftp.createFolderIfNotExist("Everything");
    print(await ftp.listDirectoryContentOnlyNames());
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        splashColor: Colors.transparent,
        icon:
            const Icon(Icons.drive_folder_upload_outlined, color: Colors.black),
        label: const Text("Upload",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 8.0,
        onPressed: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => Upload(ftp: ftp)));
        },
      ),
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
      body: !isLoading
          ? RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.red[400],
              onRefresh: () async {
                return initializeFTP();
              },
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: 200,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(
                    "$index",
                    style: const TextStyle(color: Colors.black),
                  ));
                },
              ),
            )
          : const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  // backgroundColor: kMaterialBlack,
                  color: Colors.black,
                ),
              ),
            ),
    );
  }
}
