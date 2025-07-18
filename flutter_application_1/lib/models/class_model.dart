class SchoolClass {
  final String objectId;
  final String name;
  final String? description;

  SchoolClass({
    required this.objectId,
    required this.name,
    this.description,
  });

  factory SchoolClass.fromParseObject(Map<String, dynamic> data) {
    return SchoolClass(
      objectId: data['objectId'] ?? '',
      name: data['classname'] ?? '',
      description: data['description'],
    );
  }
}
