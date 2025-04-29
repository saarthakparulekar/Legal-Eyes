import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SectionInfo {
  final String section;
  final String title;
  final String description;
  final double score;

  SectionInfo({
    required this.section,
    required this.title,
    required this.description,
    required this.score,
  });

  factory SectionInfo.fromJson(Map<String, dynamic> json) {
    return SectionInfo(
      section: json['Section'].toString(),
      title: json['Title'],
      description: json['Description'],
      score: (json['Score'] as num).toDouble(),
    );
  }
}

class LegalVerdict {
  final SectionInfo verdict;
  final List<SectionInfo> matches;

  LegalVerdict({required this.verdict, required this.matches});

  factory LegalVerdict.fromJson(Map<String, dynamic> json) {
    return LegalVerdict(
      verdict: SectionInfo.fromJson(json['Verdict']),
      matches: (json['Matches'] as List)
          .map((e) => SectionInfo.fromJson(e))
          .toList(),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String description;
  final LegalVerdict verdict;

  const ResultPage({
    Key? key,
    required this.description,
    required this.verdict,
  }) : super(key: key);

  Widget buildVerdictCard(SectionInfo info) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Section ${info.section}: ${info.title}",
              style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              info.description,
              style: GoogleFonts.rubik(fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              "Relevance Score: ${info.score.toStringAsFixed(3)}",
              style: GoogleFonts.rubik(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crime Description:',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: GoogleFonts.rubik(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Main Verdict:',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
                fontSize: 18,
              ),
            ),
            buildVerdictCard(verdict.verdict),
            const SizedBox(height: 20),
            if (verdict.matches.isNotEmpty)
              Text(
                'Related Sections:',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                  fontSize: 18,
                ),
              ),
            ...verdict.matches.map(buildVerdictCard).toList(),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class ResultPage extends StatelessWidget {
//   final String description;
//   final String verdict;
//   const ResultPage({Key? key, required this.description, required this.verdict})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'R E S U L T S',
//           style: GoogleFonts.rubik(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.grey[300],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Crime Description :',
//               style: GoogleFonts.rubik(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[900],
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               description,
//               style: GoogleFonts.rubik(
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'IPC Sections :',
//               style: GoogleFonts.rubik(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[900],
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               verdict, // Replace with actual analysis logic
//               style: GoogleFonts.rubik(
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
