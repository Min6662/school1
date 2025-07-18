class Teacher {
  final String objectId;
  final String fullName;
  final String subject;
  final String gender;
  final String? photoUrl;
  final int yearsOfExperience;

  Teacher({
    required this.objectId,
    required this.fullName,
    required this.subject,
    required this.gender,
    this.photoUrl,
    this.yearsOfExperience = 0,
  });

  factory Teacher.fromParseObject(Map<String, dynamic> data) {
    return Teacher(
      objectId: data['objectId'] ?? '',
      fullName: data['fullName'] ?? '',
      subject: data['subject'] ?? '',
      gender: data['gender'] ?? '',
      photoUrl: data['photo'],
      yearsOfExperience: data['yearsOfExperience'] ?? 0,
    );
  }
}
