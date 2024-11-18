// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:aimemosnap/screens/diary_write_screen.dart';
import 'package:aimemosnap/screens/diary_list_screen.dart';
import 'package:aimemosnap/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);  // const 생성자 추가

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _children;  // late 추가

  @override
  void initState() {
    super.initState();
    _children = [
      const DiaryListScreen(),     // const 추가
      const DiaryWriteScreen(),    // const 추가
      const ProfileScreen(),       // const 추가
    ];
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(  // const 추가
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E88E5), Color(0xFF004D40)],
          ),
        ),
        child: _children[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(  // const 추가
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E88E5), Color(0xFF004D40)],
          ),
        ),
        child: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          items: const [  // const 추가
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: '일기',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: '작성',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '프로필',
            ),
          ],
        ),
      ),
    );
  }
}