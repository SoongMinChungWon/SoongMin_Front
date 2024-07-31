import 'package:flutter_riverpod/flutter_riverpod.dart';

class User {
  final int userId;
  final String loginId;
  final String name;
  final String major;

  User({
    required this.userId,
    required this.loginId,
    required this.name,
    required this.major,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      loginId: json['loginId'],
      name: json['name'],
      major: json['major'],
    );
  }
}

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

final loginProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
