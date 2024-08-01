import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sw/core/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3초 후에 LoginMain 페이지로 이동
    Timer(Duration(seconds: 3), () {
      refreshNotifier.value = !refreshNotifier.value; // 상태 업데이트
      GoRouter.of(rootNavigatorKey.currentContext!)
          .go('/login'); // GlobalKey를 사용하여 페이지 전환
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Color(0xff87ceeb),
      splashIconSize: MediaQuery.sizeOf(context).width,
      duration: 3000,
      splash: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 50,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              '숭민청원',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      nextScreen: Container(), // 임시로 Placeholder 사용
      splashTransition:
          SplashTransition.fadeTransition, // 스플래시 화면 전환 애니메이션 설정 (옵션)
    );
  }
}
