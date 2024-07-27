import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw/src/custom_drawer.dart';
import 'package:sw/src/home.dart';

class Agreement extends ConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey9 = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: _scaffoldKey9,
      appBar: AppBar(
        title: Text(
          '내가 동의한 청원',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff87ceeb),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            ref.read(filterProvider.notifier).state = 0;
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Notification 버튼을 눌렀을 때 오른쪽에서 Drawer 열기
              _scaffoldKey9.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: Expanded(
        child: ListView(
          children: [
            PetitionCard(
              title: '도서관 에어컨',
              description: '도서관 에어컨 너무 약해요',
              category: '시설',
              agreement: 70,
              disagreement: 30,
            ),
            PetitionCard(
              title: '도서관 화장실',
              description: '화장실이 너무 더러워요',
              category: '시설',
              agreement: 70,
              disagreement: 30,
            ),
            PetitionCard(
              title: '도서관 자리',
              description: '시험기간에 반납이 안됩니다ㅠ',
              category: '시설',
              agreement: 80,
              disagreement: 20,
            ),
          ],
        ),
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(label: Text(category)),
              ],
            ),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_down, color: Colors.red),
                    SizedBox(width: 5),
                    Text('$disagreement%'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_up, color: Colors.blue),
                    SizedBox(width: 5),
                    Text('$agreement%'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: disagreement / 100,
              backgroundColor: Colors.blue,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
