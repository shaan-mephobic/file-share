import 'package:cloud_firestore/cloud_firestore.dart';

/// This class consists of all the functions that has to do with firebase
class FirebaseStuffs {
  Future<void> uploadFile(
      {required String docReference,
      required String filename,
      required String uploader,
      required String uploaderImage,
      required String fileSize,
      required int time}) async {
    await FirebaseFirestore.instance
        .collection("files")
        .doc(docReference)
        .update({
      "filename": filename,
      "size": fileSize,
      "uploader": uploader,
      "uploaderImage": uploaderImage,
      "docReference": docReference,
      "time": time,
      "history": []
    });
  }

  Future<String> generateDocID() async {
    DocumentReference docRef =
        (await FirebaseFirestore.instance.collection("files").add({}));
    return docRef.id;
  }

  Future<void> updateHistory(String docReference, List history) async {
    await FirebaseFirestore.instance
        .collection("files")
        .doc(docReference)
        .update({"history": history});
  }

  // getUserInfo({required String userId}) async {
  //   final data =
  //       await FirebaseFirestore.instance.collection("user").doc(userId).get();
  //   return data.data();
  // }

  // setUserInfo({required Map<String, dynamic> data}) async {
  //   FirebaseFirestore.instance.collection("user").doc(data['uid']).set(data);
  // }

  // getRequests({required String userId}) async {
  //   final data = await FirebaseFirestore.instance
  //       .collection("request")
  //       .where('uid', isEqualTo: userId)
  //       .get();
  //   return data.docs;
  // }

  // getRequest({required String requestId}) async {
  //   final data = await FirebaseFirestore.instance
  //       .collection("request")
  //       .doc(requestId)
  //       .get();
  //   return data.data();
  // }

  // setRequest(
  //     {required List<Uint8List?> imageData,
  //     required Map<String, dynamic> data}) async {
  //   Map requestData = data;

  //   String _id = FirebaseFirestore.instance.collection("request").doc().id;
  //   requestData['requestId'] = _id;
  //   requestData['closedDate'] = null;
  //   requestData['stationId'] = null;
  //   requestData['subDivision'] = null;
  //   requestData['lastChecked'] = null;
  //   requestData['remarks'] = null;
  //   requestData['images'] = [
  //     await postImages(imageData[0], "${_id}_1.jpg"),
  //     await postImages(imageData[1], "${_id}_2.jpg")
  //   ];
  //   FirebaseFirestore.instance.collection("request").doc(_id).set(data);
  // }

  // postImages(Uint8List? data, String fileName) async {
  //   if (data == null) {
  //     return null;
  //   } else {
  //     final _storage = FirebaseStorage.instance;
  //     var snapshot = await _storage.ref().child(fileName).putData(data);
  //     return await snapshot.ref.getDownloadURL();
  //   }
  // }

  // Future<String?> getImages({required imageName}) async {
  //   try {
  //     final data = FirebaseStorage.instance.ref().child(imageName);
  //     return await data.getDownloadURL();
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // closeRequest({required String id}) async {
  //   await FirebaseFirestore.instance
  //       .collection("request")
  //       .doc(id)
  //       .update({'status': "completed"});
  // }

  // extendRequest(
  //     {required String id,
  //     required DateTime endDate,
  //     required String purpose2}) async {
  //   print(endDate);
  //   await FirebaseFirestore.instance
  //       .collection("request")
  //       .doc(id)
  //       .update({'endDate': Timestamp.fromDate(endDate), "makku": "shaan"});
  //   String purpose =
  //       (await FirebaseFirestore.instance.collection("request").doc(id).get())
  //           .data()!['purpose'];
  //   await FirebaseFirestore.instance
  //       .collection("request")
  //       .doc(id)
  //       .update({'purpose': "$purpose\n[EXTEND]\n$purpose2"});
  // }
}
