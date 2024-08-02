import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sw/core/provider/login_provider.dart';
import 'package:sw/src/custom_drawer.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PostDetailScreen extends ConsumerWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey30 = GlobalKey<ScaffoldState>();
  final int postId;

  PostDetailScreen({required this.postId});

  Future<PostDetail?> fetchPostDetail(int postId) async {
    try {
      final response =
          await http.get(Uri.parse('http://52.79.169.32:8080/api/posts'));
      if (response.statusCode == 200) {
        List<dynamic> posts = jsonDecode(utf8.decode(response.bodyBytes));
        for (var post in posts) {
          if (post['postId'] == postId) {
            return PostDetail.fromJson(post);
          }
        }
      } else {
        throw Exception('Failed to load post detail');
      }
    } catch (e) {
      print('Error fetching post detail: $e');
      return null;
    }
    return null;
  }

  Future<PostDetail?> fetchPostDetailWithAnswer(int postId) async {
    try {
      final response = await http
          .get(Uri.parse('http://52.79.169.32:8080/api/posts/answer/$postId'));
      if (response.statusCode == 200) {
        List<dynamic> posts = jsonDecode(utf8.decode(response.bodyBytes));
        for (var post in posts) {
          if (post['postId'] == postId) {
            return PostDetail.fromJson(post);
          }
        }
      } else {
        throw Exception('Failed to load post detail with answer');
      }
    } catch (e) {
      print('Error fetching post detail with answer: $e');
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginInfo = ref.read(loginProvider);
    return Scaffold(
      key: _scaffoldKey30, // Scaffold의 키로 설정
      appBar: AppBar(
        title: Text(
          '청원글 상세페이지',
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
              _scaffoldKey30.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: FutureBuilder<PostDetail?>(
        future: fetchPostDetail(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final post = snapshot.data!;

          if (post.postType == 'state1') {
            return State1Detail(post: post, myUserId: loginInfo!.userId);
          } else if (post.postType == 'state2') {
            return State2Detail(post: post, myUserId: loginInfo!.userId);
          } else if (post.postType == 'state3') {
            return State3Detail(post: post, myUserId: loginInfo!.userId);
          } else if (post.postType == 'state4') {
            return FutureBuilder<PostDetail?>(
              future: fetchPostDetailWithAnswer(postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data available'));
                }

                final postWithAnswer = snapshot.data!;
                return State4Detail(
                    post: postWithAnswer, myUserId: loginInfo!.userId);
              },
            );
          } else {
            return Center(child: Text('Unsupported post type'));
          }
        },
      ),
    );
  }
}

class State1Detail extends HookWidget {
  final PostDetail post;
  final int myUserId;

  State1Detail({required this.post, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    final totalVotes = useState(post.agree + post.disagree);
    final agreeVotes = useState(post.agree);
    final disagreeVotes = useState(post.disagree);

    final endDate = post.createdAt.add(Duration(days: 14));
    final remainingDays = endDate.difference(DateTime.now()).inDays;
    final formattedStartDate = DateFormat('yyyy.MM.dd').format(post.createdAt);
    final formattedEndDate = DateFormat('yyyy.MM.dd').format(endDate);

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
            title: Text('익명의 글쓴이'),
            trailing: ElevatedButton(
              onPressed: () {},
              child: Text(post.postCategory),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝으로 정렬
            children: [
              Text(
                '투표 기간: $formattedStartDate ~ $formattedEndDate D-$remainingDays',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '${totalVotes.value} votes',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.thumb_down, color: Colors.black),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinearProgressIndicator(
                    value: agreeVotes.value / 30,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                  ),
                ),
              ),
              Icon(Icons.thumb_up, color: Colors.black),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    await addPostDisagree(post.postId, myUserId);
                    disagreeVotes.value++;
                    totalVotes.value++;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('비동의에 성공했습니다')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이미 투표하셨습니다')),
                    );
                  }
                },
                child: Text(
                  '비동의',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await addPostAgree(post.postId, myUserId);
                    agreeVotes.value++;
                    totalVotes.value++;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('동의에 성공했습니다')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('이미 투표하셨습니다')),
                    );
                  }
                },
                child: Text(
                  '동의',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class State2Detail extends HookWidget {
  final PostDetail post;
  final int myUserId;
  State2Detail({required this.post, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = useTextEditingController();
    final comments = useState<List<Comment>>([]);
    final agreeVotes = useState(post.agree);
    final disagreeVotes = useState(post.disagree);

    final isAddingComment = useState(false);
    Future<void> fetchCommentsList() async {
      try {
        final fetchedComments = await fetchComments(post.postId);
        comments.value = fetchedComments;
      } catch (e) {
        print('Error fetching comments: $e');
      }
    }

    void commentPush() {
      if (commentController.text.isEmpty) return;

      isAddingComment.value = true;

      addComment(post.postId, myUserId, commentController.text).then((_) {
        commentController.clear();
        fetchCommentsList(); // 댓글 추가 후 목록 새로고침
      }).catchError((e) {
        commentController.clear();
        print('Error adding comment: $e');
      }).whenComplete(() {
        isAddingComment.value = false;
      });
    }

    useEffect(() {
      fetchCommentsList();
      return null; // 클린업 함수 필요 시 정의 가능
    }, [fetchCommentsList()]); // 빈 배열을 두 번째 인자로 전달하여 처음 로드 시 한 번만 실행

    final endDate = post.createdAt.add(Duration(days: 14));
    final remainingDays = endDate.difference(DateTime.now()).inDays;
    final formattedStartDate = DateFormat('yyyy.MM.dd').format(post.createdAt);
    final formattedEndDate = DateFormat('yyyy.MM.dd').format(endDate);
    var totalVotes = post.agree + post.disagree;
    if (totalVotes == 0) {
      totalVotes = 1;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                title: Text('익명의 글쓴이'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(post.postCategory),
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
              SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투표 기간: $formattedStartDate ~ $formattedEndDate D-$remainingDays',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${post.agree + post.disagree} votes',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.red),
                    onPressed: () async {
                      try {
                        await addPostDisagree(post.postId, myUserId);
                        disagreeVotes.value++;
                        totalVotes++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비동의에 성공했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 25,
                            child: LinearProgressIndicator(
                              value: post.disagree / totalVotes,
                              backgroundColor: Colors.lightBlue[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${((post.disagree / totalVotes) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${((post.agree / totalVotes) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.lightBlue),
                    onPressed: () async {
                      try {
                        await addPostAgree(post.postId, myUserId);
                        agreeVotes.value++;
                        totalVotes++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('동의에 성공했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: comments.value.length,
                itemBuilder: (context, index) {
                  final comment = comments.value[index];
                  return ListTile(
                    title: Text(comment.commentContent),
                    subtitle: Text(
                        DateFormat('yyyy.MM.dd').format(comment.createdDate)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await deleteComment(comment.commentId);
                        fetchCommentsList();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  commentPush();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class State3Detail extends HookWidget {
  final PostDetail post;
  final int myUserId;

  State3Detail({required this.post, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController commentController = useTextEditingController();
    final comments = useState<List<Comment>>([]);
    final isAddingComment = useState(false);
    final agreeVotes = useState(post.agree);
    final disagreeVotes = useState(post.disagree);

    // 댓글 목록을 가져오는 함수
    Future<void> fetchCommentsList() async {
      try {
        final fetchedComments = await fetchComments(post.postId);
        comments.value = fetchedComments;
      } catch (e) {
        print('Error fetching comments: $e');
      }
    }

    void commentPush() {
      if (commentController.text.isEmpty) return;

      isAddingComment.value = true;

      addComment(post.postId, myUserId, commentController.text).then((_) {
        commentController.clear();
        fetchCommentsList(); // 댓글 추가 후 목록 새로고침
      }).catchError((e) {
        commentController.clear();
        print('Error adding comment: $e');
      }).whenComplete(() {
        isAddingComment.value = false;
      });
    }

    // 초기 로드 시 댓글 목록 가져오기
    useEffect(() {
      fetchCommentsList();
      return null; // 클린업 함수 필요 시 정의 가능
    }, [fetchCommentsList()]); // 빈 배열을 두 번째 인자로 전달하여 처음 로드 시 한 번만 실행

    final endDate = post.createdAt.add(Duration(days: 14));
    final remainingDays = endDate.difference(DateTime.now()).inDays;
    final formattedStartDate = DateFormat('yyyy.MM.dd').format(post.createdAt);
    final formattedEndDate = DateFormat('yyyy.MM.dd').format(endDate);
    var totalVotes = post.agree + post.disagree;
    if (totalVotes == 0) {
      totalVotes = 1;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                title: Text('익명의 글쓴이'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(post.postCategory),
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
              SizedBox(height: 70),
              Text(
                '답변:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '답변 대기중입니다',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투표 기간: $formattedStartDate ~ $formattedEndDate D-$remainingDays',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${post.agree + post.disagree} votes',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.red),
                    onPressed: () async {
                      try {
                        await addPostDisagree(post.postId, myUserId);
                        disagreeVotes.value++;
                        totalVotes++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비동의에 성공했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 25,
                            child: LinearProgressIndicator(
                              value: post.disagree / totalVotes,
                              backgroundColor: Colors.lightBlue[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${((post.disagree / totalVotes) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${((post.agree / totalVotes) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.lightBlue),
                    onPressed: () async {
                      try {
                        await addPostAgree(post.postId, myUserId);
                        agreeVotes.value++;
                        totalVotes++;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('동의에 성공했습니다')),
                        );
                        // 투표 후 댓글 목록 새로고침
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: comments.value.length,
                itemBuilder: (context, index) {
                  final comment = comments.value[index];
                  return ListTile(
                    title: Text(comment.commentContent),
                    subtitle: Text(
                        DateFormat('yyyy.MM.dd').format(comment.createdDate)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await deleteComment(comment.commentId);
                        fetchCommentsList(); // 댓글 삭제 후 목록 새로고침
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  commentPush();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class State4Detail extends HookWidget {
  final PostDetail post;
  final int myUserId;
  final TextEditingController commentController = TextEditingController();

  State4Detail({required this.post, required this.myUserId});

  @override
  Widget build(BuildContext context) {
    // useState를 사용하여 comments 상태를 관리
    final comments = useState<List<Comment>>([]);
    var totalVotes = post.agree + post.disagree;
    if (totalVotes == 0) {
      totalVotes = 1;
    }

    // 댓글을 가져오는 함수
    Future<void> _fetchComments() async {
      try {
        final fetchedComments = await fetchComments(post.postId);
        comments.value = fetchedComments; // 상태 업데이트
      } catch (e) {
        print('Error fetching comments: $e');
      }
    }

    final isAddingComment = useState(false);
    Future<void> fetchCommentsList() async {
      try {
        final fetchedComments = await fetchComments(post.postId);
        comments.value = fetchedComments;
      } catch (e) {
        print('Error fetching comments: $e');
      }
    }

    void commentPush() {
      if (commentController.text.isEmpty) return;

      isAddingComment.value = true;

      addComment(post.postId, myUserId, commentController.text).then((_) {
        commentController.clear();
        fetchCommentsList(); // 댓글 추가 후 목록 새로고침
      }).catchError((e) {
        commentController.clear();
        print('Error adding comment: $e');
      }).whenComplete(() {
        isAddingComment.value = false;
      });
    }

    useEffect(() {
      fetchCommentsList();
      return null; // 클린업 함수 필요 시 정의 가능
    }, [fetchCommentsList()]); // 빈 배열을 두 번째 인자로 전달하여 처음 로드 시 한 번만 실행

    // 댓글을 추가하는 함수
    Future<void> _addComment() async {
      final content = commentController.text;
      if (content.isNotEmpty) {
        try {
          await addComment(post.postId, myUserId, content);
          commentController.clear();
          await _fetchComments(); // 댓글 목록 갱신
        } catch (e) {
          print('Error adding comment: $e');
        }
      }
    }

    useEffect(() {
      _fetchComments();
    }, []); // 컴포넌트가 처음 로드될 때 _fetchComments 호출

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
                title: Text('익명의 글쓴이'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(post.postCategory),
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
              SizedBox(height: 40),
              Text(
                '답변:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                post.answer ?? '답변이 없습니다.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '투표 기간: ${DateFormat('yyyy.MM.dd').format(post.createdAt)} ~ ${DateFormat('yyyy.MM.dd').format(post.createdAt.add(Duration(days: 14)))} D-${post.createdAt.add(Duration(days: 14)).difference(DateTime.now()).inDays}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${totalVotes} votes',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.red),
                    onPressed: () async {
                      try {
                        await addPostDisagree(post.postId, myUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('비동의에 성공했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 25,
                            child: LinearProgressIndicator(
                              value: post.disagree /
                                  (totalVotes).toDouble(),
                              backgroundColor: Colors.lightBlue[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${((post.disagree / (totalVotes)) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${((post.agree / (totalVotes)) * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.lightBlue),
                    onPressed: () async {
                      try {
                        await addPostAgree(post.postId, myUserId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('동의에 성공했습니다')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('이미 투표하셨습니다')),
                        );
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: comments.value.length,
                itemBuilder: (context, index) {
                  final comment = comments.value[index];
                  return ListTile(
                    title: Text(comment.commentContent),
                    subtitle: Text(
                        DateFormat('yyyy.MM.dd').format(comment.createdDate)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await deleteComment(comment.commentId);
                        _fetchComments();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                commentPush();
              },
            ),
          ],
        ),
      ),
    );
  }
}

final filterProvider = StateProvider<int>((ref) => 0);

class PostDetail {
  final int postId;
  final int userId;
  final String postCategory;
  final String postType;
  final String title;
  final String content;
  final int participants;
  final int agree;
  final int disagree;
  final DateTime createdAt;
  final String? answer;

  PostDetail({
    required this.postId,
    required this.userId,
    required this.postCategory,
    required this.postType,
    required this.title,
    required this.content,
    required this.participants,
    required this.agree,
    required this.disagree,
    required this.createdAt,
    this.answer,
  });

  factory PostDetail.fromJson(Map<String, dynamic> json) {
    return PostDetail(
      postId: json['postId'],
      userId: json['userId'],
      postCategory: json['postCategory'],
      postType: json['postType'],
      title: json['title'],
      content: json['content'],
      participants: json['participants'],
      agree: json['agree'],
      disagree: json['disagree'],
      createdAt: DateTime.parse(json['createdAt']),
      answer: json['answer'],
    );
  }
}

Future<List<Comment>> fetchComments(int postId) async {
  final response = await http
      .get(Uri.parse('http://52.79.169.32:8080/api/comments/post/$postId'));

  if (response.statusCode == 200) {
    // List<dynamic> comments = json.decode(response.body);
    List<dynamic> comments = jsonDecode(utf8.decode(response.bodyBytes));
    return comments.map((comment) => Comment.fromJson(comment)).toList();
  } else {
    throw Exception('Failed to load comments');
  }
}

Future<void> addComment(int postId, int userId, String content) async {
  print(postId);
  print(content);
  print(userId);

  final response = await http.post(
    Uri.parse('http://52.79.169.32:8080/api/comments/add/$postId/$userId'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'commentContent': content}),
  );
  print(response.body);

  if (response.statusCode != 201) {
    throw Exception('Failed to add comment');
  }
}

Future<void> deleteComment(int commentId) async {
  final response = await http.delete(
    Uri.parse('http://52.79.169.32:8080/api/comments/delete/$commentId'),
  );
  print(response.body);
  if (response.statusCode != 204) {
    throw Exception('Failed to delete comment');
  }
}

class Comment {
  final int commentId;
  final int postId;
  final int userId;
  final String commentContent;
  final DateTime createdDate;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.commentContent,
    required this.createdDate,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'],
      postId: json['postId'],
      userId: json['userId'],
      commentContent: json['commentContent'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

Future<void> addPostAgree(int postId, int userId) async {
  final response = await http.post(
    Uri.parse('http://52.79.169.32:8080/api/posts/$postId/agree/$userId'),
  );

  if (response.statusCode == 204) {
    throw Exception();
  } else if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to agree to post');
  }
}

Future<void> addPostDisagree(int postId, int userId) async {
  final response = await http.post(
    Uri.parse('http://52.79.169.32:8080/api/posts/$postId/disagree/$userId'),
  );

  if (response.statusCode == 204) {
    throw Exception();
  } else if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to agree to post');
  }
}

final commentController = TextEditingController();
