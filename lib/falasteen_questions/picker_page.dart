import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class PickerPage extends StatelessWidget {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Asset> resultList = List<Asset>();
  var logger = Logger();
  signIn() async {
    firebaseAuth.signInWithEmailAndPassword(
        email: 'yasser@gmail.com', password: 'qwertyui');
  }

  Future<void> loadAssets() async {
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
      );
    } on Exception catch (e) {
      logger.e(e.toString());
    }
  }

  Future<String> saveImageToStorage(Asset asset, String imageName) async {
    try {
      ByteData byteData = await asset.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      TaskSnapshot taskSnapshot = await firebaseStorage
          .ref('products/$imageName.jpg')
          .putData(imageData);
      String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } on Exception catch (e) {
      // TODO
    }
  }

  ////////////////////////////////////////////////////////////////////
  Future<List<String>> uploadAllImages(List<Asset> assets) async {
    try {
      List<String> imagesUrl = [];
      for (int i = 0; i < assets.length; i++) {
        String imageUrl = await saveImageToStorage(assets[i], 'product$i');
        imagesUrl.add(imageUrl);
      }
      return imagesUrl;
    } on Exception catch (e) {
      logger.e(e.toString());
    }
  }

//////////////////////////////////////////////////////////////////
  addNewImagesToFirestore(List<Asset> images) async {
    try {
      List<String> imagesUrl = await uploadAllImages(images);
      DocumentReference documentReference =
          await firestore.collection('products').add({'images': imagesUrl});
      logger.d(documentReference.id);
    } on Exception catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(onPressed: () {
            signIn();
          }),
          RaisedButton(onPressed: () async {
            await loadAssets();
            await addNewImagesToFirestore(resultList);
          }),
        ],
      ),
    ));
  }
}
