import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('승민청원'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back button press
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
            },
          ),
        ],
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(
                  'https://example.com/profile.jpg', // Replace with actual profile image URL
                ),
              ),
              title: Text('대우혁'),
              subtitle: Text('컴퓨터학부\n학번 / 20201830'),
            ),
            SizedBox(height: 20),
            buildMenuButton('내가 쓴 글', Colors.green),
            SizedBox(height: 10),
            buildMenuButton('내 토론장', Colors.cyan),
            SizedBox(height: 10),
            buildMenuButton('내가 동의한 글', Colors.lightBlue),
            Spacer(),
            logoutButton(),
          ],
        ),
      ),
    );
  }

  Widget buildMenuButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () {
        // Handle button press
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget logoutButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle logout button press
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        '로그아웃',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
