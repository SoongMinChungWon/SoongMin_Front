import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sw/src/create.dart';
import 'package:sw/src/custom_drawer.dart';

// 청원 데이터 모델 정의
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

class Ai extends ConsumerStatefulWidget {
  @override
  _AiState createState() => _AiState();
}

class _AiState extends ConsumerState<Ai> {
  final GlobalKey<ScaffoldState> _scaffoldKey20 = GlobalKey<ScaffoldState>();
  List<Petition> posts = [];
  bool isLoading = true; // 데이터 로딩 상태
  bool hasError = false; // 에러 상태

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  // 필터링된 게시물을 가져오는 함수
  Future<void> fetchPosts() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final petitionState = ref.read(petitionProvider);
    final String title = petitionState['title'] ?? '';
    final String content = petitionState['content'] ?? '';

    final Map<String, dynamic> petitionData = {
      'title': title,
      'content': content,
    };

    try {
      final response = await http.post(
        Uri.parse('http://52.79.169.32:8080/api/posts/ai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(petitionData),
      );
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey20,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'AI 유사도 찾기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff87ceeb),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _scaffoldKey20.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                fetchPosts();
              },
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : hasError
                      ? Center(child: Text('Error loading posts'))
                      : ListView.builder(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final petition = posts[index];
                            return PetitionCard(
                              title: petition.title,
                              description: petition.content,
                              category: petition.postCategory,
                              agreement: petition.agree,
                              disagreement: petition.disagree,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class PetitionCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final int agreement;
  final int disagreement;

  PetitionCard({
    required this.title,
    required this.description,
    required this.category,
    required this.agreement,
    required this.disagreement,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> categoryMapping = {
      'facility': '시설',
      'event': '행사',
      'partnership': '제휴',
      'study': '교과',
      'report': '신고 합니다'
    };

    final int totalVotes = agreement + disagreement;
    final double agreementPercentage =
        totalVotes > 0 ? (agreement / totalVotes) * 100 : 0;
    final double disagreementPercentage =
        totalVotes > 0 ? (disagreement / totalVotes) * 100 : 0;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.6,
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Chip(
                    label: SizedBox(
                        width: 70,
                        child: Text(
                          categoryMapping[category] ?? category,
                          textAlign: TextAlign.center,
                        ))),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_down, color: Colors.red),
                    SizedBox(width: 5),
                    Text('${disagreementPercentage.toStringAsFixed(1)}%'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.blue),
                    SizedBox(width: 5),
                    Text('${agreementPercentage.toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalVotes > 0 ? disagreement / totalVotes : 0,
              backgroundColor: Colors.blue,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
