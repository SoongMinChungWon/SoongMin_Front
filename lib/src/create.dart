import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sw/core/provider/category_state.dart';
import 'package:sw/core/provider/login_provider.dart';
import 'package:sw/src/custom_drawer.dart';

// 청원 데이터 상태를 관리하는 StateNotifier
class PetitionState extends StateNotifier<Map<String, String>> {
  PetitionState() : super({'title': '', 'content': ''});

  void updateTitle(String title) {
    state = {...state, 'title': title};
  }

  void updateContent(String content) {
    state = {...state, 'content': content};
  }

  void reset() {
    state = {'title': '', 'content': ''};
  }
}

final petitionProvider =
    StateNotifierProvider<PetitionState, Map<String, String>>(
        (ref) => PetitionState());

class Create extends ConsumerStatefulWidget {
  @override
  _CreateState createState() => _CreateState();
}

class _CreateState extends ConsumerState<Create> {
  final GlobalKey<ScaffoldState> _scaffoldKey5 = GlobalKey<ScaffoldState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _categoryValue;

  final Map<String, String> _categoryMapping = {
    '시설': 'facility',
    '행사': 'event',
    '제휴': 'partnership',
    '교과': 'study',
    '신고 합니다': 'report'
  };

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);
    final categoryNotifier = ref.read(categoryProvider.notifier);
    final petitionState = ref.watch(petitionProvider);
    final petitionNotifier = ref.read(petitionProvider.notifier);

    return Scaffold(
      key: _scaffoldKey5,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '청원 하기',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff87ceeb),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
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
              _scaffoldKey5.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                petitionNotifier.updateTitle(value);
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DropdownButton<String>(
                          icon: Icon(Icons.filter_list),
                          value: _categoryValue,
                          items: _categoryMapping.keys
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _categoryValue = newValue;
                            });
                            if (newValue != null) {
                              categoryNotifier.updateCategory(newValue);
                            }
                          },
                          hint: categoryState.selectedCategory != null &&
                                  categoryState.selectedCategory!.isNotEmpty
                              ? Text(
                                  categoryState.selectedCategory!,
                                  style: TextStyle(color: Colors.black),
                                )
                              : Text('카테고리',
                                  style: TextStyle(color: Colors.black)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/ai');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff1A4957),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'AI유사글찾기',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: '동의가 70%가 넘으면 작성한 글이 학교 측으로 전달되니 참고해주세요!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                petitionNotifier.updateContent(value);
              },
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await _submitPetition();
              },
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text('청원 게시하기', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff1A4957),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPetition() async {
    final loginInfo = ref.read(loginProvider);
    final petitionState = ref.read(petitionProvider);
    final String title = petitionState['title']!;
    final String content = petitionState['content']!;
    final String? category = _categoryMapping[_categoryValue];

    if (title.isEmpty || content.isEmpty || category == null) {
      // 적절한 오류 처리를 해주세요.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 채워주세요.')),
      );
      return;
    }

    final Map<String, dynamic> petitionData = {
      'title': title,
      'content': content,
      'categoryId': category,
      'typeId': 'state1' // 필요에 따라 typeId를 지정하세요.
    };

    final response = await http.post(
      Uri.parse('http://52.79.169.32:8080/api/posts/${loginInfo!.userId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(petitionData),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      // 성공적으로 게시됨
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('청원이 성공적으로 게시되었습니다.')),
      );
      Navigator.pop(context); // 화면을 종료합니다.
    } else {
      // 실패 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('청원 게시에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }
}
