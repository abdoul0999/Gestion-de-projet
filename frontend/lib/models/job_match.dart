class CertificationItem {
  final String title;
  final String platform;
  final String duration;
  final String price;
  final String priority;
  final String reason;

  const CertificationItem({
    required this.title,
    required this.platform,
    required this.duration,
    required this.price,
    required this.priority,
    required this.reason,
  });

  factory CertificationItem.fromJson(Map<String, dynamic> j) => CertificationItem(
        title: j['title'] ?? '',
        platform: j['platform'] ?? '',
        duration: j['duration'] ?? '',
        price: j['price'] ?? '',
        priority: j['priority'] ?? 'medium',
        reason: j['reason'] ?? '',
      );
}

class JobMatch {
  final int id;
  final String jobTitle;
  final String? company;
  final double matchScore;
  final List<String> strongSkills;
  final List<String> missingSkills;
  final List<CertificationItem> certifications;
  final DateTime createdAt;

  const JobMatch({
    required this.id,
    required this.jobTitle,
    this.company,
    required this.matchScore,
    required this.strongSkills,
    required this.missingSkills,
    required this.certifications,
    required this.createdAt,
  });

  factory JobMatch.fromJson(Map<String, dynamic> j) => JobMatch(
        id: j['id'],
        jobTitle: j['job_title'] ?? '',
        company: j['company'],
        matchScore: (j['match_score'] as num).toDouble(),
        strongSkills: List<String>.from(j['strong_skills'] ?? []),
        missingSkills: List<String>.from(j['missing_skills'] ?? []),
        certifications: (j['certifications'] as List)
            .map((e) => CertificationItem.fromJson(e))
            .toList(),
        createdAt: DateTime.parse(j['created_at']),
      );
}
