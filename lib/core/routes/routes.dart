import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:sw/reuse/bottom_nav.dart';
import 'package:sw/src/LoginMian.dart';
import 'package:sw/src/home.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);
final GoRouter router = GoRouter(
  //이 부분 없으니까 처음 화면 그냥 보라색으로 뜨는 경우도 있음. 초기화면 지정해 놓은 부분이야
  navigatorKey: rootNavigatorKey,
  refreshListenable: refreshNotifier,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const BottomNav(),
        );
      },
      branches: [
        //여러 개의 StatefulShellBranch를 포함
        //각 브랜치는 하나의 경로 집합
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => Home(),
            ),
          ],
        ),
      ],
    ),
    //초기화면 지정하는 부분
    GoRoute(
      path: '/',
      builder: (context, state) => LoginMain(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => Home(),
    ),
  ],
);
