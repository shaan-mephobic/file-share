import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpConnect.dart';
import 'package:share/constant/constants.dart';
import 'package:share/pages/download.dart';
import 'package:share/pages/upload.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FTPConnect ftp = FTPConnect(Constants.ipAddress,
      user: 'admin', pass: 'password', port: 2121);
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    initializeFTP();
  }

  Future<void> initializeFTP() async {
    await ftp.connect();
    await ftp.createFolderIfNotExist("Everything");
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: scaffoldKey,
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                'ver 1.0',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ListTile(
              title: const Text('Log Out'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => Upload(ftp: ftp)));
        },
      ),
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.),
        //   onPressed: () => scaffoldKey.currentState?.openDrawer(),
        // ),
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
              key: refreshKey,
              color: Colors.white,
              backgroundColor: Colors.red[400],
              onRefresh: () async {
                return initializeFTP();
              },
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("files")
                    // .limit(12)

                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  //filter snapshots
                  snapshot = snapshot;

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No data",
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w600)));
                  }
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: snapshot.data?.docs.length,
                    padding: EdgeInsets.only(bottom: screenHeight / 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 3 / 4,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      // return ClipRRect(
                      //   borderRadius: BorderRadius.circular(5),
                      //   child: Stack(
                      //     children: [
                      //       SizedBox(
                      //         height: 150,
                      //         width: 150,
                      //         child: Image.network(
                      //           snapshot.data?.docs[index]["uploaderImage"] ??
                      //               "",
                      //           fit: BoxFit.cover,
                      //           width: double.infinity,
                      //           height: double.infinity,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // );
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => FileDownload(
                                        fileDetails: snapshot.data!.docs[index],
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 0, bottom: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Hero(
                                        tag: snapshot.data!.docs[index]
                                            ["docReference"],
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          // margin: EdgeInsets.all(50),
                                          // color: Colors.grey[300],
                                          // child: Center(
                                          // child: SizedBox(
                                          //   width: screenWidth / 9,
                                          //   child: AspectRatio(
                                          //     aspectRatio: 5 / 6,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.black26,
                                                      offset: Offset(0, 2),
                                                      blurRadius: 6),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  //   ),
                                  // ),
                                  // ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth / 75 + 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Text(
                                          snapshot.data?.docs[index]
                                              ["filename"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 19),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
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
                                                  snapshot.data?.docs[index]
                                                      ["uploaderImage"],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Text(
                                              snapshot.data?.docs[index]
                                                  ["uploader"],
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      );
                    },
                  );
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
