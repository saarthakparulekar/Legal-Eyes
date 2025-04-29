class SectionInfo {
  final int section;
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
      section: json['Section'],
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