import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legal_eyes/pages/homepage.dart';
import 'package:legal_eyes/pages/scanner.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome to Legal Eyes!',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),),
                    ],
                  ),
                  SizedBox(height: 30,),
                  ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => FelonyDescriptionScreen())),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 200),
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.keyboard_alt_outlined, color: Colors.black,size: 40,),
                          Text('Type the description',
                          style: GoogleFonts.rubik(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),),
                        ],
                      )
                  ),
                  SizedBox(height: 30,),
                  ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScannerPage())),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(100, 200),
                        elevation: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.camera_alt_outlined, color: Colors.black, size: 40,),
                          Text('Scan the description',
                          style: GoogleFonts.rubik(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),)
                        ],
                      ))
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
