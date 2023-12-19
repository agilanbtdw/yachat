class Profile {
  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  final bool isMine;

  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.isMine,
  });

  Profile.fromMap({required Map<String, dynamic> map, required String myUserId})
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['id'];
}
