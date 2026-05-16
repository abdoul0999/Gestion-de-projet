class SkillItem {
  final String name;
  final int level;
  const SkillItem({required this.name, required this.level});
  factory SkillItem.fromJson(Map<String, dynamic> j) =>
      SkillItem(name: j['name'], level: (j['level'] as num).toInt());
}

class CorrectionItem {
  final String rule;
  final String status; // ok | error | warning
  final String? suggestion;
  const CorrectionItem({required this.rule, required this.status, this.suggestion});
  factory CorrectionItem.fromJson(Map<String, dynamic> j) => CorrectionItem(
        rule: j['rule'],
        status: j['status'],
        suggestion: j['suggestion'],
      );
}

class CVAnalysis {
  final int id;
  final String? filename;
  final double? score;
  final List<SkillItem> skills;
  final List<CorrectionItem> corrections;
  final List<String> softSkills;
  final List<String> languages;
  final DateTime createdAt;

  const CVAnalysis({
    required this.id,
    this.filename,
    this.score,
    required this.skills,
    required this.corrections,
    required this.softSkills,
    required this.languages,
    required this.createdAt,
  });

  factory CVAnalysis.fromJson(Map<String, dynamic> j) => CVAnalysis(
        id: j['id'],
        filename: j['filename'],
        score: j['score'] != null ? (j['score'] as num).toDouble() : null,
        skills: (j['skills'] as List).map((e) => SkillItem.fromJson(e)).toList(),
        corrections:
            (j['corrections'] as List).map((e) => CorrectionItem.fromJson(e)).toList(),
        softSkills: List<String>.from(j['soft_skills'] ?? []),
        languages: List<String>.from(j['languages'] ?? []),
        createdAt: DateTime.parse(j['created_at']),
      );
}
