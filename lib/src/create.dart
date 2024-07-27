import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw/core/provider/category_state.dart';
import 'package:sw/src/custom_drawer.dart';

class Create extends ConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey5 = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String categoryValue = '';
    final categoryState = ref.watch(categoryProvider);
    final categoryNotifier = ref.watch(categoryProvider.notifier);
    return Scaffold(
      key: _scaffoldKey5,
      appBar: AppBar(
        title: Text(
          '청원 하기',
          style: TextStyle(fontWeight: FontWeight.bold),
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
              decoration: InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.9,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DropdownButton<String>(
                        icon: Icon(Icons.filter_list),
                        value: categoryValue.isNotEmpty ? categoryValue : null,
                        items: <String>['시설', '제휴', '교과', '행사']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          newValue!;
                          categoryNotifier.updateCategory(newValue);
                        },
                        hint: categoryState.selectedCategory != ''
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
                SizedBox(width: 10),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 12,
              decoration: InputDecoration(
                hintText: '동의가 70%가 넘으면 작성한 글이 학교 측으로 전달되니 참고해주세요!',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                context.pop();
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
                minimumSize: Size(double.infinity, 50), // 버튼의 최소 크기 설정
              ),
            ),
          ],
        ),
      ),
    );
  }
}
