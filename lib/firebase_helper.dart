import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

FirebaseStorage storage = FirebaseStorage.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
var logger = Logger();
Future<String> saveAssetImage(Asset asset, String name) async {
  try {
    ByteData byteData = await asset.getByteData();
    List<int> imageData = byteData.buffer.asUint8List();

    TaskSnapshot upload =
        await storage.ref('shady/$name.jpg').putData(imageData);

    String downloadURL = await upload.ref.getDownloadURL();
    logger.e(downloadURL);
    return downloadURL;
  } on Exception catch (e) {
    print('/////////////////////////////');
    logger.e(e);
    print('/////////////////////////////');
    return null;
  }
}

Future<List<String>> uploadAllImages(
    List<Asset> assets, String marketName) async {
  List<String> urls = [];
  for (int i = 0; i < assets.length; i++) {
    String url = await saveAssetImage(assets[i], '$marketName' + '$i');
    urls.add(url);
  }
  return urls;
}

Future<String> addNewImagesToFireStore(List<Asset> images) async {
  try {
    List<String> urls = await uploadAllImages(images, 'omar');
    logger.e(urls);

    DocumentReference documentReference =
        await firestore.collection('products').add({'images': urls});

    return documentReference.id;
  } on Exception catch (e) {
    return null;
  }
}
