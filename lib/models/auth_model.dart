class User {
  final int id;
  final String email;
  final String accessToken;
  final String tokenType;

  User({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.tokenType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      email: json['user']['email'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}
