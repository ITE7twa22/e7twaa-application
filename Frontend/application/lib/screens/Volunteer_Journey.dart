import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ProfileScreen.dart';

class VolunteerJourneyScreen extends StatefulWidget {
  const VolunteerJourneyScreen({super.key});

  @override
  _VolunteerJourneyScreenState createState() => _VolunteerJourneyScreenState();
}

class _VolunteerJourneyScreenState extends State<VolunteerJourneyScreen> {
  int _selectedIndex = 2; // Default selected index
void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToScreen(const ProfileScreen());
        break;
      case 1:
           _navigateToScreen(const HomeScreen());

        break;
      case 2:
        _navigateToScreen(const VolunteerJourneyScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFBB040),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 35),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 35),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: '',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child:
                Image.asset('assets/background_image.jpeg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
            child: const Center(
              child: Text(
                "قريــبــًا",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
