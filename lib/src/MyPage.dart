import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sw/core/provider/login_provider.dart';
import 'package:sw/core/provider/nav_provider.dart';
import 'package:sw/src/custom_drawer.dart';
import 'package:sw/src/home.dart';

class MyPage extends ConsumerWidget {
  // GlobalKey를 사용하여 Scaffold의 상태를 관리
  final GlobalKey<ScaffoldState> _scaffoldKey3 = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navStateProvider);
    final loginInfo = ref.read(loginProvider);
    return Scaffold(
      key: _scaffoldKey3, // Scaffold의 key로 설정
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          navState.title,
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(filterProvider.notifier).state = 0;
            context.pop();
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
              // Notification 버튼을 눌렀을 때 오른쪽에서 Drawer 열기
              _scaffoldKey3.currentState?.openEndDrawer();
            },
          ),
        ],
        backgroundColor: Color(0xff87ceeb),
      ),
      endDrawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  child: const Icon(Icons.person),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loginInfo!.major ?? '20201830',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    Text(
                      loginInfo.name ?? '20201830',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Text(
                          '학번 / ',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          loginInfo.loginId ?? '20201830',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.push('/mypage/mypost');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff22C55E),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '내가 쓴 청원',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.push('/mypage/participants');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff08F3E7),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '내가 참여한 청원',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.push('/mypage/agreement');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff87CEEB),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '내가 동의한 청원',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            )
          ],
        ),
      ),
    );
  }
}
