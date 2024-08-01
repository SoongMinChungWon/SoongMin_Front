import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:sw/src/MyPage.dart';

import 'package:sw/src/LoginMian.dart';
import 'package:sw/src/Main_Screen.dart';
import 'package:sw/src/ai.dart';
import 'package:sw/src/complete.dart';
import 'package:sw/src/create.dart';
import 'package:sw/src/home.dart';
import 'package:sw/src/mypage/agreement.dart';
import 'package:sw/src/mypage/my_post.dart';
import 'package:sw/src/mypage/participants.dart';
import 'package:sw/src/proceeding.dart';
import 'package:sw/src/search.dart';
import 'package:sw/src/wait.dart';
import 'package:sw/src/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  refreshListenable: refreshNotifier,
  initialLocation: '/',
  errorPageBuilder: (context, state) {
    return MaterialPage(
      child: Scaffold(
        body: Center(
          child: Text('페이지를 찾을 수 없습니다.'),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: "/login",
      pageBuilder: (BuildContext context, GoRouterState state) =>
          NoTransitionPage(child: LoginMain()),
    ),
    GoRoute(
      path: '/main',
      builder: (context, state) => MainScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => Home(),
    ),
    GoRoute(
      path: '/wait',
      builder: (context, state) => Wait(),
    ),
    GoRoute(
      path: '/proceeding',
      builder: (context, state) => Proceeding(),
    ),
    GoRoute(
      path: '/complete',
      builder: (context, state) => Complete(),
    ),
    GoRoute(
      path: '/mypage',
      builder: (context, state) => MyPage(),
    ),
    GoRoute(
      path: '/mypage/mypost',
      builder: (context, state) => MyPost(),
    ),
    GoRoute(
      path: '/ai',
      builder: (context, state) => Ai(),
    ),
    GoRoute(
      path: '/mypage/participants',
      builder: (context, state) => Participants(),
    ),
    GoRoute(
      path: '/mypage/agreement',
      builder: (context, state) => Agreement(),
    ),
    GoRoute(
      path: '/create',
      builder: (context, state) => Create(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => Search(),
    ),
  ],
);
