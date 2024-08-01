import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:sw/core/routes/routes.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
    // 3초 후에 LoginMain 페이지로 이동
    Timer(Duration(seconds: 3), () {
      refreshNotifier.value = !refreshNotifier.value; // 상태 업데이트
      GoRouter.of(rootNavigatorKey.currentContext!)
          .go('/login'); // GlobalKey를 사용하여 페이지 전환
    });
  }

  Future<void> requestPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 162.w, // 크기를 screenutil로 조정
      duration: 3000,
      splash: Container(
        // margin:
        //     EdgeInsets.symmetric(horizontal: 114.w), // 좌우 여백을 screenutil로 비율 조정
        width: 162.w, // 너비를 screenutil로 비율 조정
        height: 127.w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splashs.png'),
            fit: BoxFit.fitWidth, // 이미지를 중앙에 고정하고 비율을 유지하며 맞춤
          ),
        ),
      ),
      nextScreen: Container(), // 임시로 Placeholder 사용
      splashTransition:
          SplashTransition.fadeTransition, // 스플래시 화면 전환 애니메이션 설정 (옵션)
    );
  }
}
