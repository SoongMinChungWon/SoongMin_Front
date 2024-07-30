import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:sw/core/provider/category_state.dart';
import 'dart:convert';

import 'package:sw/core/provider/search_provider.dart';

class Petition {
  final String title;
  final String description;
  final String category;
  final int agreement;
  final int disagreement;

  Petition({
    required this.title,
    required this.description,
    required this.category,
    required this.agreement,
    required this.disagreement,
  });

  factory Petition.fromJson(Map<String, dynamic> json) {
    return Petition(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      agreement: json['agreement'],
      disagreement: json['disagreement'],
    );
  }
}

final postsInProgressProvider = FutureProvider<List<Petition>>((ref) async {
  final response =
      await http.get(Uri.parse('http://52.79.169.32:8080/api/posts/state1'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Petition.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load posts in progress');
  }
});

final postsWaitingProvider = FutureProvider<List<Petition>>((ref) async {
  final response =
      await http.get(Uri.parse('http://52.79.169.32:8080/api/posts/state2'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Petition.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load waiting posts');
  }
});

final postsCompletedProvider = FutureProvider<List<Petition>>((ref) async {
  final response =
      await http.get(Uri.parse('http://52.79.169.32:8080/api/posts'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Petition.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load completed posts');
  }
});

class Home extends ConsumerWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchNotifier = ref.watch(searchProvider.notifier);
    final categoryState = ref.watch(categoryProvider);
    final categoryNotifier = ref.watch(categoryProvider.notifier);
    final selectedFilter = ref.watch(filterProvider);
    String searchValue = '';
    String categoryValue = '';

    void goSearch() {
      _searchController.clear();
      ref.read(filterProvider.notifier).state = 0;
      context.push('/search');
    }

    Future<void> refreshData() async {
      ref.refresh(postsInProgressProvider);
      ref.refresh(postsWaitingProvider);
      ref.refresh(postsCompletedProvider);
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    searchValue = _searchController.text;
                    searchNotifier.updateSearch(searchValue);
                    goSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              icon: Icon(Icons.filter_list),
              value: categoryValue.isNotEmpty ? categoryValue : null,
              items: <String>[
                '시설',
                '제휴',
                '교과',
                '행사',
                '신고합니다',
              ].map<DropdownMenuItem<String>>((String value) {
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilterRadio(
                  label: '최다동의순',
                  value: 0,
                  groupValue: selectedFilter,
                  onChanged: (int? value) {
                    ref.read(filterProvider.notifier).state = value!;
                  },
                ),
                FilterRadio(
                  label: '만료임박순',
                  value: 1,
                  groupValue: selectedFilter,
                  onChanged: (int? value) {
                    ref.read(filterProvider.notifier).state = value!;
                  },
                ),
                FilterRadio(
                  label: '최신순',
                  value: 2,
                  groupValue: selectedFilter,
                  onChanged: (int? value) {
                    ref.read(filterProvider.notifier).state = value!;
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshData,
              child: ListView(
                children: [
                  PetitionSection(
                    title: '답변 진행 중',
                    provider: postsInProgressProvider,
                  ),
                  PetitionSection(
                    title: '답변 대기 중',
                    provider: postsWaitingProvider,
                  ),
                  PetitionSection(
                    title: '답변 완료',
                    provider: postsCompletedProvider,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterRadio extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;

  FilterRadio({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}

class PetitionSection extends ConsumerWidget {
  final String title;
  final FutureProvider<List<Petition>> provider;

  PetitionSection({required this.title, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petitionsAsyncValue = ref.watch(provider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          petitionsAsyncValue.when(
            data: (petitions) => Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: petitions.length,
                itemBuilder: (context, index) {
                  final petition = petitions[index];
                  return PetitionCard(
                    title: petition.title,
                    description: petition.description,
                    category: petition.category,
                    agreement: petition.agreement,
                    disagreement: petition.disagreement,
                  );
                },
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
      ),
    );
  }
}

final filterProvider = StateProvider((ref) => 0);
