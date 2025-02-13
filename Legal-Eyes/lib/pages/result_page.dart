import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatelessWidget {
  final String description;
  final String verdict;
  const ResultPage({Key? key, required this.description, required this.verdict})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'R E S U L T S',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crime Description :',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: GoogleFonts.rubik(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'IPC Sections :',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              verdict, // Replace with actual analysis logic
              style: GoogleFonts.rubik(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
