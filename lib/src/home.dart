import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw/core/provider/nav_provider.dart';

class Home extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.filter_list),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
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
                Row(
                  children: [
                    Radio(value: 0, groupValue: 0, onChanged: (int? value) {}),
                    Text('최다동의순'),
                  ],
                ),
                Row(
                  children: [
                    Radio(value: 1, groupValue: 0, onChanged: (int? value) {}),
                    Text('만료임박순'),
                  ],
                ),
                Row(
                  children: [
                    Radio(value: 2, groupValue: 0, onChanged: (int? value) {}),
                    Text('최신순'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
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
                    Icon(Icons.thumb_up, color: Colors.blue),
                    SizedBox(width: 5),
                    Text('$agreement%'),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.thumb_down, color: Colors.red),
                    SizedBox(width: 5),
                    Text('$disagreement%'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: agreement / 100,
              backgroundColor: Colors.red,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
