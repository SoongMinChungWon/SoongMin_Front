// import 'package:flutter/material.dart';

// class PostDetailScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.lightBlue,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             // Handle back button press
//           },
//         ),
//         title: Text('청원글'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications),
//             onPressed: () {
//               // Handle notification button press
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '도서관 에어컨',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: Icon(Icons.circle, size: 10, color: Colors.black),
//               title: Text('대우혁'),
//               trailing: ElevatedButton(
//                 onPressed: () {},
//                 child: Text('시설'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.grey[300],
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               '도서관 에어컨 너무 약해요',
//               style: TextStyle(fontSize: 16),
//             ),
//             Spacer(),
//             Text(
//               '투표 기간: 2024.7.01 ~ 2024.7.15 D-14',
//               style: TextStyle(color: Colors.grey),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Icon(Icons.thumb_down, color: Colors.black),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: LinearProgressIndicator(
//                       value: 0.77, // 23/30 votes
//                       backgroundColor: Colors.grey[300],
//                       valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
//                     ),
//                   ),
//                 ),
//                 Icon(Icons.thumb_up, color: Colors.black),
//                 Text(
//                   '23/30',
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle disagree button press
//                   },
//                   child: Text('비동의'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     minimumSize: Size(150, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle agree button press
//                   },
//                   child: Text('동의'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.lightBlue,
//                     minimumSize: Size(150, 50),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostDetailScreen extends StatelessWidget {
  Future<PostDetail> fetchPostDetail() async {
    final response = await http.get(Uri.parse('http://52.79.169.32:8080'));
    
    if (response.statusCode == 200) {
      return PostDetail.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        title: Text('청원글'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
            },
          ),
        ],
      ),
      body: FutureBuilder<PostDetail>(
        future: fetchPostDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data'));
          }

          final post = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, size: 10, color: Colors.black),
                  title: Text(post.username),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    child: Text(post.category),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  post.content,
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                Text(
                  '투표 기간: ${post.voteStartDate} ~ ${post.voteEndDate} D-${post.daysRemaining}',
                  style: TextStyle(color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.thumb_down, color: Colors.black),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: LinearProgressIndicator(
                          value: post.voteProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                        ),
                      ),
                    ),
                    Icon(Icons.thumb_up, color: Colors.black),
                    Text(
                      '${post.votes}/${post.totalVotes}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle disagree button press
                      },
                      child: Text('비동의'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle agree button press
                      },
                      child: Text('동의'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        minimumSize: Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PostDetail {
  final String title;
  final String username;
  final String category;
  final String content;
  final String voteStartDate;
  final String voteEndDate;
  final int daysRemaining;
  final int votes;
  final int totalVotes;
  final double voteProgress;

  PostDetail({
    required this.title,
    required this.username,
    required this.category,
    required this.content,
    required this.voteStartDate,
    required this.voteEndDate,
    required this.daysRemaining,
    required this.votes,
    required this.totalVotes,
    required this.voteProgress,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    return PostDetail(
      title: json['title'],
      username: json['username'],
      category: json['category'],
      content: json['content'],
      voteStartDate: json['vote_start_date'],
      voteEndDate: json['vote_end_date'],
      daysRemaining: json['days_remaining'],
      votes: json['votes'],
      totalVotes: json['total_votes'],
      voteProgress: json['votes'] / json['total_votes'],
    );
  }
}
