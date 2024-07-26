import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sw/core/provider/nav_provider.dart';
import 'package:sw/src/bottom_nav.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(navState.title),
        backgroundColor: Color(0xff87ceeb),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: BottomNav(),
    );
  }
}
