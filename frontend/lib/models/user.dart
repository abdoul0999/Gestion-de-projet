class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? targetJob;
  final String? contractType;
  final String? region;
  final String? educationLevel;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.targetJob,
    this.contractType,
    this.region,
    this.educationLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        firstName: json['first_name'],
        lastName: json['last_name'],
        email: json['email'],
        targetJob: json['target_job'],
        contractType: json['contract_type'],
        region: json['region'],
        educationLevel: json['education_level'],
      );

  String get fullName => '$firstName ${lastName.toUpperCase()}';
  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ""}${lastName.isNotEmpty ? lastName[0] : ""}';

  bool get profileComplete =>
      targetJob != null && contractType != null && region != null;
}
