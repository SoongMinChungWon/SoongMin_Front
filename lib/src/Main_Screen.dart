import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sw/src/bottom_nav.dart';
import 'package:sw/src/custom_drawer.dart';

class MainScreen extends ConsumerWidget {
  MainScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey4 = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: _scaffoldKey4,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '숭민청원',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Color(0xff87ceeb),
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
              _scaffoldKey4.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: CustomDrawer(),
      body: BottomNav(),
    );
  }
}
