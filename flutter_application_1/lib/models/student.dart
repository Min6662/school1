class Student {
  final String objectId;
  final String name;
  final String grade;
  final String address;
  final String phoneNumber;
  final String studyStatus;
  final DateTime? dateOfBirth;
  final String? photoUrl;
  final String gender;

  Student({
    required this.objectId,
    required this.name,
    required this.grade,
    required this.address,
    required this.phoneNumber,
    required this.studyStatus,
    this.dateOfBirth,
    this.photoUrl,
    required this.gender,
  });

  factory Student.fromParseObject(Map<String, dynamic> data) {
    return Student(
      objectId: data['objectId'] ?? '',
      name: data['name'] ?? '',
      grade: data['grade'] ?? '',
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      studyStatus: data['studyStatus'] ?? '',
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.tryParse(data['dateOfBirth'])
          : null,
      photoUrl: data['photo'],
      gender: data['gender'] ?? '',
    );
  }
}
