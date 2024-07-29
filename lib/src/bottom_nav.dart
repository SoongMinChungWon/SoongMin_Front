import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:sw/core/provider/nav_provider.dart';
import 'package:sw/src/home.dart';

class BottomNav extends ConsumerStatefulWidget {
  const BottomNav({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _BottomBarState();
  }
}

class _BottomBarState extends ConsumerState<BottomNav> {
  int _activeIndex = 0;
  final iconList = <IconData>[
    Icons.assignment,
    Icons.question_answer,
    Icons.check_circle,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    final navStateNotifier = ref.watch(navStateProvider.notifier);
    return Scaffold(
      body: Home(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create');
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _activeIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        backgroundColor: Color(0xff87ceeb),
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _activeIndex = index;
            switch (index) {
              case 0:
                navStateNotifier.updateTitle('동의중인 청원');
                ref.read(filterProvider.notifier).state = 0;
                context.push('/proceeding');
                break;
              case 1:
                navStateNotifier.updateTitle('답변 대기 청원');
                ref.read(filterProvider.notifier).state = 0;
                context.push('/wait');
                break;
              case 2:
                navStateNotifier.updateTitle('답변 완료 청원');
                ref.read(filterProvider.notifier).state = 0;
                context.push('/complete');
                break;
              case 3:
                navStateNotifier.updateTitle('마이페이지');
                ref.read(filterProvider.notifier).state = 0;
                context.push('/mypage');
                break;
            }
          });
        },
        splashSpeedInMilliseconds: 300,
      ),
    );
  }
}
