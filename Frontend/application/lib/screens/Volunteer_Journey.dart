import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'ProfileScreen.dart';

class VolunteerJourneyScreen extends StatefulWidget {
  const VolunteerJourneyScreen({super.key});

  @override
  _VolunteerJourneyScreenState createState() => _VolunteerJourneyScreenState();
}

class _VolunteerJourneyScreenState extends State<VolunteerJourneyScreen> {
  int _selectedIndex = 2;
  int _currentMonthIndex = 0;

  final List<String> _months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];
  final int _currentYear = 2025;

  final Map<String, List<Map<String, String>>> _volunteerData = {
    'يناير 2025': [
      {
        'day': '28',
        'weekday': 'الثلاثاء',
        'checkIn': '09:00 PM',
        'checkOut': '12:00 PM',
        'totalHours': '03:00'
      },
      {
        'day': '29',
        'weekday': 'الأربعاء',
        'checkIn': '09:00 PM',
        'checkOut': '12:00 PM',
        'totalHours': '03:00'
      },
      {
        'day': '30',
        'weekday': 'الخميس',
        'checkIn': '09:00 PM',
        'checkOut': '12:00 PM',
        'totalHours': '03:00'
      },
      {
        'day': '31',
        'weekday': 'الجمعة',
        'checkIn': '09:00 PM',
        'checkOut': '12:00 PM',
        'totalHours': '03:00'
      },
    ],
    'فبراير 2025': [
      {
        'day': '15',
        'weekday': 'السبت',
        'checkIn': '10:00 AM',
        'checkOut': '01:00 PM',
        'totalHours': '03:00'
      },
    ],
  };

  void _changeMonth(int direction) {
    setState(() {
      _currentMonthIndex += direction;
      if (_currentMonthIndex < 0) {
        _currentMonthIndex = 0;
      }
      if (_currentMonthIndex >= _months.length) {
        _currentMonthIndex = _months.length - 1;
      }
    });
  }
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
        _navigateToScreen(const home_screen());
       
      case 2:
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    String currentMonth = '${_months[_currentMonthIndex]} $_currentYear';

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
          BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 35), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 35), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/background_image.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (رحلتي التطوعية)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF939597), width: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'رحلتي التطوعية',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFBB040)),
                      onPressed: _currentMonthIndex > 0 ? () => _changeMonth(-1) : null,
                    ),
                    Text(
                      currentMonth,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFBB040)),
                      onPressed: _currentMonthIndex < _months.length - 1 ? () => _changeMonth(1) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: ListView(
                    children: (_volunteerData[currentMonth] ?? [])
                        .map(
                          (record) => Column(
                        children: [
                          _buildVolunteerRecord(
                            record['day']!,
                            record['weekday']!,
                            record['checkIn']!,
                            record['checkOut']!,
                            record['totalHours']!,
                          ),
                          const Divider(color: Colors.black),
                        ],
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerRecord(String day, String weekday, String checkIn, String checkOut, String totalHours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              _buildStatItem(Icons.access_time_outlined, checkIn, 'مجموع الساعات', Colors.black),
              const SizedBox(width: 20),
              _buildStatItem(Icons.access_time_outlined, checkOut, 'تسجيل الخروج', Colors.black),
              const SizedBox(width: 20),
              _buildStatItem(Icons.access_time_outlined, totalHours, 'تسجيل الدخول', Colors.black),
            ],
          ),
          Container(
            width: 65,
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  weekday,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String time, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 30, color: iconColor),
        const SizedBox(height: 3),
        Text(
          time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
