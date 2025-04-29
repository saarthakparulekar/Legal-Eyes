import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legal_eyes/backend/request.dart';
import 'package:legal_eyes/pages/result_page.dart';


class FelonyDescriptionScreen extends StatefulWidget {
  @override
  _FelonyDescriptionScreenState createState() => _FelonyDescriptionScreenState();
}

class _FelonyDescriptionScreenState extends State<FelonyDescriptionScreen> {
  final TextEditingController _descriptionController = TextEditingController();


  Future<void> _submitAndAnalyze() async {
    final description = _descriptionController.text;

    const url = 'http://192.168.1.10:51561/data';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'description': description});

    try {
      final response = await putData(url, headers, body);

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final legalVerdict = LegalVerdict.fromJson(decodedData);

        print('Data sent successfully: ${response.body}');

        // ✅ Navigate to result page here, where decodedData is in scope
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              description: description,
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'L E G A L - E Y E S',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            Container(
              child: Column(
              children: [
                SizedBox(height: 20,),
                Text(
                  'Enter the description of the crime to help us analyze it and return the related IPC sections',
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30,),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Describe the crime here',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null, // Allows the text field to expand
                ),
              ],
            ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _submitAndAnalyze,
                  child: Text(
                      'Submit',
                      style: GoogleFonts.rubik(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

