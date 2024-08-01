import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Comment {
  final int commentId;
  final int postId;
  final int userId;
  final String commentContent;
  final DateTime createdDate;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.commentContent,
    required this.createdDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      postId: json['postId'],
      userId: json['userId'],
      commentContent: json['commentContent'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

class CommentNotifier extends StateNotifier<List<Comment>> {
  CommentNotifier() : super([]);

  void addComment(Comment comment) {
    state = [...state, comment];
  }

  void removeComment(int commentId) {
    state = state.where((c) => c.commentId != commentId).toList();
  }

  Future<void> fetchComments(int postId) async {
    final response = await http
        .get(Uri.parse('http://52.79.169.32:8080/api/comments/post/$postId'));

    if (response.statusCode == 200) {
      List<dynamic> comments = jsonDecode(utf8.decode(response.bodyBytes));
      state = comments.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }
}

final commentProvider =
    StateNotifierProvider<CommentNotifier, List<Comment>>((ref) {
  return CommentNotifier();
});
