class User {
  final String id;
  final String email;
  final String phoneNumber;
  final String name;
  final List<String> favorites;

  User(
      {required this.id,
      required this.email,
      required this.phoneNumber,
      required this.name,
      required this.favorites});
}
