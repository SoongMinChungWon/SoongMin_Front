import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginLogo.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'U-Saint ID로 입력하세요',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'U-Saint PW로 입력하세요',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context.go('/main');
                          },
                          child: Text('U-Saint 로그인'),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black, // 선의 색상
                                  width: 1.0, // 선의 두께
                                ),
                              ),
                            ),
                            child: Text(
                              'ID/PW 찾기',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
