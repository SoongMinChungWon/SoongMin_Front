import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

final filterProvider = StateProvider<int>((ref) => 0);

final postsInProgressProvider = FutureProvider<List<Petition>>((ref) async {
  final filter = ref.watch(filterProvider);
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

  final response = await http.get(Uri.parse(
      'http://52.79.169.32:8080/api/posts/sorted/$filterState/state12'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Petition.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load posts in progress');
  }
});

final postsWaitingProvider = FutureProvider<List<Petition>>((ref) async {
  final filter = ref.watch(filterProvider);
  String filterState;

  switch (filter) {
    case 1:
      filterState = 'agree';
      break;
    case 2:
      filterState = 'expiry';
      break;
    default:
      filterState = 'createdDate';
  }

  final response = await http.get(Uri.parse(
      'http://52.79.169.32:8080/api/posts/sorted/$filterState/state3'));
  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((json) => Petition.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load waiting posts');
  }
});

final postsCompletedProvider = FutureProvider<List<Petition>>((ref) async {
  final filter = ref.watch(filterProvider);
  String filterState;

  switch (filter) {
    case 1:
      filterState = 'agree';
      break;
    case 2:
      filterState = 'expiry';
      break;
    default:
      filterState = 'createdDate';
  }

  final response = await http.get(Uri.parse(
      'http://52.79.169.32:8080/api/posts/sorted/$filterState/state4'));
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
    final selectedFilter = ref.watch(filterProvider);

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
                    description: petition.content,
                    category: petition.postCategory,
                    agreement: petition.agree,
                    disagreement: petition.disagree,
                    postId: petition.postId,
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
      'report': '신고합니다'
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.4,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

