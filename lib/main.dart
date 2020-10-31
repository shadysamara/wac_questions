import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:picker_wac/falasteen_questions/picker_page.dart';
import 'package:picker_wac/firebase_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Scaffold(
                body: Center(
              child: Text('Error'),
            ));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return PickerPage();
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Scaffold(
              body: Center(
            child: CircularProgressIndicator(),
          ));
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;
  var logger = Logger();
  List<Asset> images = List<Asset>();
  List<Asset> resultList = List<Asset>();
  Future<void> loadAssets() async {
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
      );
    } on Exception catch (e) {
      logger.e(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(onPressed: () {
              auth.signInWithEmailAndPassword(
                  email: 'yasser@gmail.com', password: 'qwertyui');
            }),
            RaisedButton(onPressed: () async {
              await loadAssets();
              addNewImagesToFireStore(resultList);
            }),
          ],
        ),
      ),
    );
  }
}
