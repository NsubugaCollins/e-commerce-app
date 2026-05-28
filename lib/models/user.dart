class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int points;
  final String referralCode;
  final int loginCount;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.points,
    required this.referralCode,
    required this.loginCount,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code'] as String? ?? '',
      loginCount: (json['login_count'] as num?)?.toInt() ?? 0,
      role: json['role'] as String? ?? 'user',
    );
  }
}
