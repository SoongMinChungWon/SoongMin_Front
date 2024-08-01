import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final GlobalKey<ScaffoldState> _scaffoldKey20 = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  int selectedFilter = 0; // 필터 선택 상태를 나타내는 변수
  String selectedCategory = ''; // 선택된 카테고리
  List<Petition> posts = [];
  bool isLoading = true; // 데이터 로딩 상태
  bool hasError = false; // 에러 상태

  // 한글 카테고리를 영어로 변환하는 매핑
  final Map<String, String> categoryMapping = {
    '시설': 'facility',
    '행사': 'event',
    '제휴': 'partnership',
    '교과': 'study',
    '신고 합니다': 'report'
  };

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() async {
    try {
      final response =
          await http.get(Uri.parse('http://52.79.169.32:8080/api/posts'));
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

  // 필터링된 게시물을 가져오는 함수
  Future<void> fetchPosts(int filter, String category, String keyword) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    String filterState;
    switch (filter) {
      case 0:
        filterState = 'sorted-by-agree';
        break;
      case 1:
        filterState = 'sorted-by-expiry';
        break;
      default:
        filterState = 'sorted-by-created-date';
    }

    String categoryParam = categoryMapping[category] ?? '';
    print(categoryParam);
    print('Searching for: $keyword'); // 실제 검색 로직으로 대체 필요
    final Map<String, dynamic> petitionData = {
      'keyword': keyword,
    };

    try {
      final response = await http.post(
        Uri.parse(
            'http://52.79.169.32:8080/api/posts/search/sorted-by-created-date/$categoryParam'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(petitionData),
      );

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

  // 검색 버튼 클릭 시 실행되는 함수
  void goSearch() async {
    final keyword = _searchController.text;
    // 검색 키워드를 이용한 검색 로직 추가

    fetchPosts(selectedFilter, selectedCategory, keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey20,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '검색',
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
            onPressed: goSearch,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.search),
                              onPressed: goSearch,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        DropdownButton<String>(
                          icon: Icon(Icons.filter_list),
                          value: selectedCategory.isEmpty
                              ? null
                              : selectedCategory,
                          items: categoryMapping.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue ?? '';
                            });
                          },
                          hint: Text('필터 하고 싶은 카테고리를 선택하세요'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
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
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                start();
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
