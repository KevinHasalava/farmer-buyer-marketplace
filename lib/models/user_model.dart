class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.isFarmer = false,
    this.role = '',
    this.userMetadata,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isFarmer;

  /// 'farmer' | 'buyer' | 'driver' | 'admin' (from `public.profiles.role`).
  final String role;
  final Map<String, dynamic>? userMetadata;
}
