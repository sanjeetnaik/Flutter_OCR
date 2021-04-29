import 'dart:io';

import 'package:expiry_date/data.dart';
import 'package:flutter/material.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var pickedImage;
  List<String> ls = [];
  var instance = FirebaseFirestore.instance.collection("users");
  var lst = [];
  var tempimage;
  String extractText = '';
  String _url;

  bool isImageLoaded = false;

  Future pickImagee() async {
    PickedFile tempStore =
        await ImagePicker().getImage(source: ImageSource.gallery);
    tempimage = tempStore.path;
    File selected = new File(tempStore.path);

    setState(() {
      pickedImage = selected;
      isImageLoaded = true;
    });
  }

  readDataa() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String url;
    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(pickedImage);
    uploadTask.whenComplete(() {
      url = ref.getDownloadURL().toString();
    }).catchError((onError) {
      print(onError);
    });
    return url;
    var file = pickedImage;
    var storageRef = FirebaseStorage.instance.ref('rainbow_photos');
    storageRef.putFile(file).then((result) {
      storageRef.getDownloadURL().then((result) {
        _url = (result);
      });
    });
  }

  addData() async {
    String temp2 = "";
    for (int i = 0; i < ls.length; i++) {
      temp2 = temp2 + " " + ls[i];
    }
    temp2 = temp2;
    Map temp = {"data": temp2};
    print(ls);
    print(temp);
    instance.add({"data": temp2}).then((value) => print("s"));

    // instance.doc("jimmy").set(temp3).catchError((e) {
    //   print(e.toString());
    // });
  }

  Future pickImage() async {
    PickedFile tempStore = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
    File selected = new File(tempStore.path);
    setState(() {
      pickedImage = selected;
      isImageLoaded = true;
    });
  }

  Future readText() async {
    setState(() {
      ls = [];
    });

    final ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            ls.add(word.text);
          });

          print(word.text);
        }
      }
    }

    print(ls);
    // print("1");
    // extractText = await TesseractOcr.extractText(tempimage);
    // print("2");
    // print("3");
  }

  Future decode() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
    List barCodes = await barcodeDetector.detectInImage(ourImage);

    for (Barcode readableCode in barCodes) {
      print(readableCode.displayValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          isImageLoaded
              ? Center(
                  child: Container(
                      height: 220.0,
                      width: 220.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: FileImage(pickedImage),
                              fit: BoxFit.cover))),
                )
              : Container(),
          SizedBox(
            height: 60,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  height: 60,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(40)),
                  child: FlatButton(
                    child: Text(
                      'Click an image',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    onPressed: pickImage,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 60,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(40)),
                  child: FlatButton(
                    child: Text(
                      'Pick an image',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    onPressed: pickImagee,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 60,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40)),
                  child: FlatButton(
                      child: Text(
                        'Read Text',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      onPressed: () async {
                        await readText();
                        await addData();
                      }),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  height: 60,
                  width: 170,
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(40)),
                  child: FlatButton(
                    child: Text(
                      'Previous Data',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Data()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
