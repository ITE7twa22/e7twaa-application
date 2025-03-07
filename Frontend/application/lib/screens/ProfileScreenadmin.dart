import 'package:flutter/material.dart';


class ProfileScreenadmin extends StatefulWidget {
  const ProfileScreenadmin({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreenadmin> {
  int _selectedIndex = 0;

  void _showUserDataSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'بياناتي',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الاسم',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                    ),
                  ),
                  SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'الرقم',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        child: Text(
                          '+966  |',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 90),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFBB040),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 115, vertical: 10),
                        child: Text(
                          'تعديل',
                          style: TextStyle(color: Colors.white, fontSize: 26),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
      // case 0:
      //   break;
      //   break;
      // case 1:
      //   _navigateToScreen(const HomeScreen());
      // case 2:
      //   _navigateToScreen(const VolunteerJourneyScreen());
      //   break;
    }
  }
  void _showCertificatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text('شهاداتي',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.download, color: Color(0xFFFBB040)),
                            SizedBox(height: 10),
                            Icon(Icons.edit, color: Color(0xFFFBB040)),
                          ],
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('pdf. مشاعل العبدالكريم',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '197KB - 22 December 2024 at 3:36 PM',
                                style: TextStyle(color: Colors.grey , fontSize: 13,),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                        Image.asset('assets/PDF_file.png', width: 60, height: 60),
                      ],
                    ),
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );

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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
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
            child: Image.asset('assets/background_image.jpeg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الملف الشخصي',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.grey[200],
                  child: Icon(Icons.account_circle, size: 90, color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      'لمياء عبدالله السحيباني',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ركن الجلابيات',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF939697), // Use the color here
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            ':قائد',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFF97CAEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('عضو نشط', style: TextStyle(color: Colors.white, fontSize: 19)),
                ),
                const SizedBox(height: 30),
                _buildProfileOptionsContainer(),
                const SizedBox(height: 10),
                _buildProfileOptionContainer('تواصل معنا', Icons.phone_outlined),
                const SizedBox(height: 10),
                _buildProfileOptionContainer('تسجيل الخروج', Icons.exit_to_app, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionsContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileOption('بياناتي', Icons.person_outline, withBorder: true, onTap: _showUserDataSheet),
          const SizedBox(height: 15),
          _buildProfileOption('شهاداتي', Icons.insert_drive_file_outlined,withBorder: true, onTap: _showCertificatesSheet),
          const SizedBox(height: 15),
          _buildProfileOption('الفريق', Icons.people_outline),
        ],
      ),
    );
  }
  Widget _buildProfileOptionContainer(String title, IconData icon, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical:8.5, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: _buildProfileOption(title, icon, color: color),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, {Color color = Colors.black, bool withBorder = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.5, horizontal: 8),
        decoration: withBorder
            ? BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.arrow_back_ios, color: Colors.grey, size: 18),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: color),
                textAlign: TextAlign.right,
              ),
            ),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }
}
