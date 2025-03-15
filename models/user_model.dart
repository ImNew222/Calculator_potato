class UserModel {
  final String uid;
  final String username;
  final String email;
  final DateTime timestamp;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.timestamp,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "username": username,
      "email": email,
      "timestamp": timestamp.toIso8601String(), // Convert DateTime to String
    };
  }

  // Convert from Firestore Document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      username: map["username"] ?? "",
      email: map["email"] ?? "",
      timestamp:
          DateTime.parse(map["timestamp"] ?? DateTime.now().toIso8601String()),
    );
  }
}
