class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isFarmer = false,
  });

  final String id;
  final String name;
  final String email;
  final bool isFarmer;
}
