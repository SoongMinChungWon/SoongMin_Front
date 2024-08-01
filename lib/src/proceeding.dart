import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
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

class Proceeding extends StatefulWidget {
  @override
  _ProceedingState createState() => _ProceedingState();
}

class _ProceedingState extends State<Proceeding> {
  final GlobalKey<ScaffoldState> _scaffoldKey2 = GlobalKey<ScaffoldState>();
  int selectedFilter = 0;
  List<Petition> posts = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPosts(selectedFilter);
  }

  Future<void> fetchPosts(int filter) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String filterState;
    switch (filter) {
      case 0:
        filterState = 'agree';
        break;
      case 1:
        filterState = 'expiry';
        break;
      default:
        filterState = 'createdDate';
    }

    try {
      final response = await http.get(Uri.parse(
          'http://52.79.169.32:8080/api/posts/sorted/$filterState/state12'));
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
      key: _scaffoldKey2,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '답변 중인 청원',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
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
              _scaffoldKey2.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(), // CustomDrawer 사용을 고려하세요.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterRadio(
                  value: 0,
                  groupValue: selectedFilter,
                  label: '최다동의순',
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                    fetchPosts(value);
                  },
                ),
                FilterRadio(
                  value: 1,
                  groupValue: selectedFilter,
                  label: '만료임박순',
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                    fetchPosts(value);
                  },
                ),
                FilterRadio(
                  value: 2,
                  groupValue: selectedFilter,
                  label: '최신순',
                  onChanged: (value) {
                    setState(() {
                      selectedFilter = value;
                    });
                    fetchPosts(value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                fetchPosts(selectedFilter);
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
                              postId: petition.postId,
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

class FilterRadio extends StatelessWidget {
  final int value;
  final int groupValue;
  final String label;
  final ValueChanged<int> onChanged;

  const FilterRadio({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: (int? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
        Text(label),
      ],
    );
  }
}

class PetitionCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final int agreement;
  final int disagreement;
  final int postId;

  PetitionCard({
    required this.title,
    required this.description,
    required this.category,
    required this.agreement,
    required this.disagreement,
    required this.postId,
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

    return GestureDetector(
      onTap: () {
        context.push('/postDetail/$postId');
      },
      child: Card(
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
      ),
    );
  }
}
