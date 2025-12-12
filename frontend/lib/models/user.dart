class User {
  final int id;
  final String username;
  final String whatsapp;
  
  User({
    required this.id,
    required this.username,
    required this.whatsapp,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      whatsapp: json['whatsapp'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'whatsapp': whatsapp,
    };
  }
}