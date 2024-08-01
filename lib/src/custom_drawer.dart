import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:sw/core/provider/login_provider.dart';
import 'dart:convert';

import 'package:sw/src/custom_drawer.dart';

class Petition {
  final int postId;
  final int userId;
  final String postCategory;
  final String postType;
  final String title;
  final String content;
  final int participants;
  final int agree;
  final int disagree;

  Petition({
    required this.postId,
    required this.userId,
    required this.postCategory,
    required this.postType,
    required this.title,
    required this.content,
    required this.participants,
    required this.agree,
    required this.disagree,
  });

  factory Petition.fromJson(Map<String, dynamic> json) {
    return Petition(
      postId: json['postId'],
      userId: json['userId'],
      postCategory: json['postCategory'],
      postType: json['postType'],
      title: json['title'],
      content: json['content'],
      participants: json['participants'],
      agree: json['agree'],
      disagree: json['disagree'],
    );
  }
}

class CustomDrawer extends ConsumerStatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends ConsumerState<CustomDrawer> {
  int selectedFilter = 0;
  List<Petition> posts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final loginInfo = ref.read(loginProvider);
    try {
      final response = await http.get(
          Uri.parse('http://52.79.169.32:8080/api/alarm/${loginInfo!.userId}'));
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> data =
            jsonDecode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          posts = data.map((json) => Petition.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final loginInfo = ref.watch(loginProvider);

        return Drawer(
          child: Column(
            children: [
              Container(
                height: 150,
                child: DrawerHeader(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xffc2c2c2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: const Icon(Icons.person),
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              loginInfo!.major,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Text(
                              loginInfo.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  '학번 / ',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                Text(
                                  loginInfo.loginId,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final petition = posts[index];
                    String state = petition.postType == 'state4'
                        ? '청원글에 답변이 달렸어요!'
                        : '동의 비율이 70%를 넘어 메일이 전송되었어요!';
                    String message = '${petition.title} : $state';

                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(message),
                      onTap: () {
                        // 알림 클릭 시 동작
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
