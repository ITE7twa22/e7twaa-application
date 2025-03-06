import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'Volunteer_Journey.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreen createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  int _selectedIndex = 0;
  String userName = '';  // Initial value
  String status = '';
  String phoneNumber = ''; // Initial value

  @override
  void initState() {
    super.initState();
    // Load the user name when the screen is initialized
    getNameUser();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  VolunteerJourneyScreen()),
      );
    }
  }

  Future<void> getNameUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('ArabicName') ?? 'User';  // Update the value and rebuild
      status = prefs.getString('status') ?? 'status';  // Update the value and rebuild
      phoneNumber = prefs.getString('phoneNumber') ?? 'phoneNumber';  // Update the value and rebuild
    });
  }
  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      userName,
                      textAlign: TextAlign.right,
                    ),
                  )
                  ,

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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          phoneNumber,
                          textAlign: TextAlign.right,
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 90),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFBB040),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 115, vertical: 10),
                        child: Text(
                          'إغلاق',
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


  void _showCertificatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  Center(
                    child: Text('.... قريبا ',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  ),

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
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
                      userName,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFFBB040),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status,
                      style: TextStyle(color: Colors.white, fontSize: 19)),
                ),
                const SizedBox(height: 30),
                _buildProfileOptionsContainer(),
                const SizedBox(height: 15),
                _buildProfileOptionContainerContactUs(
                  'تواصل معنا',
                  Icons.phone_outlined,
                      () => _launchURL('https://forms.gle/aoeoqR64c9nQEAYi6'),
                ),
                const SizedBox(height: 15),
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
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileOption('بياناتي', Icons.person_outline, withBorder: true, onTap: _showUserDataSheet),
          _buildProfileOption('شهاداتي', Icons.insert_drive_file_outlined, onTap: _showCertificatesSheet),
        ],
      ),
    );
  }

  Widget _buildProfileOptionContainer(String title, IconData icon, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: _buildProfileOption(title, icon, color: color),
    );
  }

  Widget _buildProfileOptionContainerContactUs(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: _buildProfileOption(title, icon),
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, {Color color = Colors.black, bool withBorder = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: withBorder ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))) : null,
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

