class SchoolClass {
  final String id;
  final String name;
  final List<String> studentIds;
  final List<String> teacherIds;

  SchoolClass(
      {required this.id,
      required this.name,
      required this.studentIds,
      required this.teacherIds});
}
