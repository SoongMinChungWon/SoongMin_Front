import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw/core/provider/category_state.dart';
import 'package:sw/core/provider/nav_provider.dart';
import 'package:sw/core/provider/search_provider.dart';
import 'package:sw/src/custom_drawer.dart';
import 'package:sw/src/home.dart';

class Search extends ConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey10 = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.watch(searchProvider.notifier);
    final categoryState = ref.watch(categoryProvider);
    final categoryNotifier = ref.watch(categoryProvider.notifier);
    String searchValue = '';
    String categoryValue = '';
    _searchController.text = searchState.searchContent ?? searchValue;
    void goSearch() {
      _searchController.clear();
      context.push('/search');
    }

    return Scaffold(
      key: _scaffoldKey10,
      appBar: AppBar(
        title: Text(
          '검색',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff87ceeb),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            ref.read(filterProvider.notifier).state = 0;
            searchState.searchContent = '';
            categoryState.selectedCategory = '';
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _scaffoldKey10.currentState?.openEndDrawer();
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
                              onPressed: () {
                                searchValue = _searchController.text;
                                searchNotifier.updateSearch(searchValue);
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        DropdownButton<String>(
                          icon: Icon(Icons.filter_list),
                          value:
                              categoryValue.isNotEmpty ? categoryValue : null,
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
                              ? Text(categoryState.selectedCategory!)
                              : Text('필터 하고 싶은 카테고리를 선택하세요'),
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
            child: Consumer(
              builder: (context, ref, child) {
                final selectedFilter = ref.watch(filterProvider);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: selectedFilter,
                          onChanged: (int? value) {
                            ref.read(filterProvider.notifier).state = value!;
                          },
                        ),
                        Text('최다동의순'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<int>(
                          value: 1,
                          groupValue: selectedFilter,
                          onChanged: (int? value) {
                            ref.read(filterProvider.notifier).state = value!;
                          },
                        ),
                        Text('만료임박순'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<int>(
                          value: 2,
                          groupValue: selectedFilter,
                          onChanged: (int? value) {
                            ref.read(filterProvider.notifier).state = value!;
                          },
                        ),
                        Text('최신순'),
                      ],
                    ),
                  ],
                );
              },
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
