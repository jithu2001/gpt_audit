class User {
  final int userId;
  final String email;
  final String fullName;
  final String role;
  final String? status;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.status,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isActive => status?.toLowerCase() == 'active';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      status: json['account_status'] ?? json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'full_name': fullName,
      'role': role,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'User(userId: $userId, email: $email, fullName: $fullName, role: $role, status: $status)';
  }
}
