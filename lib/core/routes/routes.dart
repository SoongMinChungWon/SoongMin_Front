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

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);
final GoRouter router = GoRouter(
  //이 부분 없으니까 처음 화면 그냥 보라색으로 뜨는 경우도 있음. 초기화면 지정해 놓은 부분이야
  navigatorKey: rootNavigatorKey,
  refreshListenable: refreshNotifier,
  initialLocation: '/',
  routes: [
    //초기화면 지정하는 부분
    GoRoute(
      path: '/',
      builder: (context, state) => LoginMain(),
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
