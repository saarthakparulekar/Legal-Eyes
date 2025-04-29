import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:legal_eyes/backend/request.dart';
import 'dart:convert';

import 'package:legal_eyes/pages/result_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  File? _image;
  String _extractedText = '';
  final ImagePicker _picker = ImagePicker();
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Image picker function
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
      _extractTextFromImage();
    }
  }

  // Extract text using updated Google ML Kit
  Future<void> _extractTextFromImage() async {
    final inputImage = InputImage.fromFilePath(_image!.path);
    final RecognizedText recognisedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      _extractedText = recognisedText.text;
    });

    // Send text to backend
    _sendTextToBackend(_extractedText);
  }

  // Function to send extracted text to backend
  Future<void> _sendTextToBackend(String text) async {
    final url = 'http://192.168.1.10:51561/data';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'description': text});

    try {
      final response = await putData(url, headers, body);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final legalVerdict = LegalVerdict.fromJson(decodedData);

        print('Data sent successfully: ${response.body}');

        // ✅ Navigate here with structured data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              description: text,
              verdict: legalVerdict,
            ),
          ),
        );
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    textRecognizer.close(); // Properly dispose of the recognizer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'L E G A L - E Y E S',
          style: GoogleFonts.rubik(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
      ),
      body: Column(
        children: [
          if (_image != null) Image.file(_image!),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 200),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_copy_outlined,
                      color: Colors.black,
                    ),
                    Text(
                      'Upload Image',
                      style: GoogleFonts.rubik(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, 200),
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
                Text(
                  'Scan Image',
                  style: GoogleFonts.rubik(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _sendTextToBackend(_extractedText),
            child: Text(
              'Submit',
              style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
