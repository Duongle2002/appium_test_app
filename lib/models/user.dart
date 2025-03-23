class User {
  final String name;
  final String email;
  final String? id;

  User({required this.name, required this.email, this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class AuthResponse {
  final String message;
  final String? accessToken;
  final User? user;

  AuthResponse({required this.message, this.accessToken, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      accessToken: json['accessToken'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}