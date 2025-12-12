class UserModel {
  final String uid;
  final String email;
  final String name;

  // 1. CONSTANT CONSTRUCTOR
  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
  });

  // 2. TO MAP (Dart -> Database)
  // We cannot send a 'Class' to Firebase. We must send a 'Map' (JSON).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  // 3. FROM MAP (Database -> Dart)
  // When we read from Firebase, we get a Map. We need to convert it back to our Class.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
    );
  }
}