import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_face_detector/FacePainter.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetector extends StatefulWidget {
  @override
  _FaceDetectorState createState() => _FaceDetectorState();
}

class _FaceDetectorState extends State<FaceDetector> {
  File _imageFile;
  List<Face> _faces;
  bool isLoading = false;
  ui.Image _image;

  Future getImage(bool camera) async {
    File image;

    if (camera) {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
      
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
      
    }

    setState(() {
      _imageFile = image;
      isLoading = true;
    });

    detectFaces(_imageFile);
  }

  detectFaces(File imageFile) async {
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);

    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
        _loadImage(imageFile);
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
          _image = value;
          isLoading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Face Detector"),
      ),
      body: isLoading
          ? Center(
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(child: CircularProgressIndicator())),
            )
          : (_imageFile == null)
              ? Center(
                  child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.height / 2,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text("No Image Selected"))),
                )
              : Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: FittedBox(
                      child: SizedBox(
                        width: _image.width.toDouble(),
                        height: _image.height.toDouble(),
                        child: CustomPaint(
                          painter: FacePainter(_image, _faces),
                        ),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _imageFile = null;
                });
              },
              child: Icon(Icons.refresh),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                getImage(true);
              },
              child: Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(
              onPressed: () {
                getImage(false);
              },
              child: Icon(Icons.image),
            ),
          )
        ],
      ),
    );
  }
}
