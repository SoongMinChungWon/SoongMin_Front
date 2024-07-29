import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 150,
            child: DrawerHeader(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xffc2c2c2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
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
                          '컴퓨터학부',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        Text(
                          '대우혁',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              '학번 / ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                            Text(
                              '20201830',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('동의 비율이 70%를 넘어 메일이 전송되었어요!'),
            onTap: () {
              // 알림 클릭 시 동작
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('청원글에 답변이 달렸어요!'),
            onTap: () {
              // 알림 클릭 시 동작
            },
          ),
          // 추가 알림 항목을 여기에 추가할 수 있습니다.
        ],
      ),
    );
  }
}
