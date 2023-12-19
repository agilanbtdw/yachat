import 'package:my_chat_app/models/followable_state.dart';
import 'package:my_chat_app/utils/constants.dart';

class Profile {
  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  /// Date and time when the profile was created
  final DateTime createdAt;

  final bool isMine;

  final FollowableState followableState;

  Profile({
    required this.id,
    required this.username,
    required this.createdAt,
    required this.followableState,
    required this.isMine,
  });

  Profile.fromMap({required Map<String, dynamic> map, required String myUserId})
      : id = map['id'],
        username = map['username'],
        createdAt = DateTime.parse(map['created_at']),
        followableState =
            _getFollowableStateFromString(map['followable_state']),
        isMine = myUserId == map['id'];

  static FollowableState _getFollowableStateFromString(String value) {
    switch (value) {
      case PERMISSION_LEVEL_FOLLOWABLE:
        return FollowableState.followable;
      case PERMISSION_LEVEL_NOT_FOLLOWABLE:
        return FollowableState.notFollowable;
      case PERMISSION_LEVEL_NOT_ACCESSIBLE:
        return FollowableState.notAccessible;
      default:
        return FollowableState.notAccessible;
    }
  }
}
