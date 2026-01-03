import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:frimages/ML/Recognition.dart';
import 'package:frimages/ML/Recognizer.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _HomePageState();
}

class _HomePageState extends State<RegistrationScreen> {
  File? _image;
  late ImagePicker imagePicker;
  late FaceDetector faceDetector;
  late Recognizer recognizer;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();

    //TODO initialize face detector
    final options = FaceDetectorOptions(enableClassification: true);
    faceDetector = FaceDetector(options: options);

    //TODO initialize face recognizer
    recognizer = Recognizer(numThreads: 2);
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await doFaceDetection();
      setState(() {});
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await doFaceDetection();
      setState(() {});
    }
  }

  //TODO face detection code here
  List<Face> faces = [];
  doFaceDetection() async {
    //TODO remove rotation of camera images
    _image = await removeRotation(_image!);

    InputImage inputImage = InputImage.fromFile(_image!);
    faces = await faceDetector.processImage(inputImage);

    for (Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      print('Face found with bounding box:$boundingBox');

      var bytes = await _image!.readAsBytes();
      img.Image? tempImg = img.decodeImage(bytes)!;
      faceImage = img.copyCrop(
        tempImg,
        x: boundingBox.left.toInt(),
        y: boundingBox.top.toInt(),
        width: boundingBox.width.toInt(),
        height: boundingBox.height.toInt(),
      );

      Recognition recognition = recognizer.recognize(faceImage!, boundingBox);
      print('Embeddings: ${recognition.embeddings}');
    }
    drawRectanglesOnImage();
  }

  //TODO draw rectangles on image
  ui.Image? image;
  img.Image? faceImage;
  drawRectanglesOnImage() async {
    var bytes = await _image!.readAsBytes();
    image = await decodeImageFromList(bytes);
    setState(() {
      image;
      faces;
    });
  }

  //TODO Face Registration Dialogue
  TextEditingController textEditingController = TextEditingController();
  showFaceRegistrationDialogue(img.Image croppedFace, Recognition recognition) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Face Registration", textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.memory(
                    Uint8List.fromList(img.encodePng(croppedFace)),
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Name',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1f4037),
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    recognizer.registerFaceInDB(
                      textEditingController.text,
                      recognition.embeddings,
                      Uint8List.fromList(img.encodeJpg(croppedFace)),
                    );
                    textEditingController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Face Registered")),
                    );
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  //TODO remove rotation of camera images
  removeRotation(File inputImage) async {
    final img.Image? capturedImage = img.decodeImage(
      await File(inputImage.path).readAsBytes(),
    );

    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    return await File(_image!.path).writeAsBytes(img.encodeJpg(orientedImage));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1f4037), Color(0xFF99f2c8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Face Registration",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),

              // Face Preview
              Container(
                width: MediaQuery.of(context).size.width / 1.15,
                height: MediaQuery.of(context).size.width / 1.15,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24), // Rounded corners
                  gradient: const LinearGradient(
                    colors: [Color(0xFFffffff), Color(0xFFd4f7e6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(75),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    18,
                  ), // Match inner clip radius
                  child:
                      // faceImage != null
                      //     ? Image.memory(
                      //       Uint8List.fromList(img.encodePng(faceImage!)),
                      //     )
                      image != null
                          ? FittedBox(
                            child: SizedBox(
                              width: image!.width.toDouble(),
                              height: image!.height.toDouble(),
                              child: CustomPaint(
                                painter: FacePainter(
                                  facesList: faces,
                                  imageFile: image,
                                ),
                              ),
                            ),
                          )
                          : Image.asset("images/logo.png", fit: BoxFit.fill),
                ),
              ),

              const SizedBox(height: 40),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _gradientButton(
                    icon: Icons.image,
                    label: "Gallery",
                    onTap: _imgFromGallery,
                    width: screenWidth * 0.4,
                  ),
                  _gradientButton(
                    icon: Icons.camera_alt,
                    label: "Camera",
                    onTap: _imgFromCamera,
                    width: screenWidth * 0.4,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable beautiful button
  Widget _gradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double width = 150,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xFFffffff), Color(0xFFc4f1e0)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  List<Face> facesList;
  ui.Image? imageFile;
  FacePainter({required this.facesList, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile!, Offset.zero, Paint());
    }

    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 3;

    for (Face face in facesList) {
      canvas.drawRect(face.boundingBox, p);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
