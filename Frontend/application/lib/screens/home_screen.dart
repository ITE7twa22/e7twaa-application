import 'package:flutter/material.dart';
import 'Volunteer_Journey.dart';
import 'ProfileScreen.dart';
import 'package:geolocator/geolocator.dart';
import '../api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

final ApiService apiService = ApiService();
bool checkIn = false;
TimeOfDay? checkInToday;
TimeOfDay? checkOutToday;
Duration? duration;

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  bool _isPressed = false;
  double? workLatitude = 24.8340996;
  double? workLongitude =  46.7280004;

  Future<String> getNameUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstName') ?? 'User';
  }
  Future<String> getTotalHours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('totalHours') ?? '0';
  }
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double distance = Geolocator.distanceBetween(
      workLatitude!,
      workLongitude!,
      position.latitude,
      position.longitude,
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      return;
    } else {
      print("Token retrieved: $token");
    }

    if (distance > 10500) {
      _showErrorDialog("يبدو أنك خارج الموقع المحدد لتسجيل الدخول.\n"
          "تأكد من وجودك في المكان الصحيح ثم حاول مرة أخرى.");
    }
    else{
      if (!checkIn) {
        __showErrorDialogConfirm(token, "هل انت متأكد من تسجيل الدخول؟");
      } else {
        __showErrorDialogConfirm(token, "هل انت متأكد من تسجيل الخروج؟");
      }
    }
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
  void __showErrorDialogConfirm(String token, String m) {
  showDialog(
    context: context,
    builder: (context) => Directionality( // Ensuring RTL text direction for Arabic
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text("تأكيد"),
        content: Text(m),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("لا"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (!checkIn) {
                await apiService.checkin(token);

                setState(() {
                  checkIn = true;
                  checkInToday = TimeOfDay.now();
                });
              } else {
                await apiService.checkOut(token);

                setState(() {
                  checkOutToday = TimeOfDay.now();

                  if (checkInToday != null) {
                    DateTime now = DateTime.now();
                    DateTime checkInDateTime = DateTime(
                        now.year, now.month, now.day, checkInToday!.hour, checkInToday!.minute);
                    DateTime checkOutDateTime = DateTime(
                        now.year, now.month, now.day, checkOutToday!.hour, checkOutToday!.minute);
                    duration = checkOutDateTime.difference(checkInDateTime);
                  }
                  checkIn = false;
                });
              }
            },
            child: const Text("نعم"),
          ),
        ],
      ),
    ),
  );
}


    void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => Directionality( // Ensure right-to-left alignment
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          "خارج الموقع",
          textAlign: TextAlign.right, // Align text to the right
        ),
        content: Text(
          message,
          textAlign: TextAlign.right, // Align text to the right
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("حسناً"),
          ),
        ],
      ),
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
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF939597), width: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'احتواء',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/Logo.jpeg',
                        width: 40,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.only(right: 23),
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: getNameUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error fetching user');
                      } else if (snapshot.hasData) {
                        return Text(
                          'مرحبًا بك ${snapshot.data}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        );
                      } else {
                        return const Text('مرحبًا بك');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.only(right: 23),
                  alignment: Alignment.centerRight,
                  child: FutureBuilder<String>(
                    future: getTotalHours(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('Error fetching hours');
                      } else if (snapshot.hasData) {
                        return Text(
                          'ساهمت بـ ${snapshot.data} ساعة تطوعية في كسوة فرح',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        );
                      } else {
                        return const Text('ساهمت بـ 0 ساعة تطوعية في كسوة فرح');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 80),
                Center(
                  child: Container(
                    width: 330,
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(65),
                            onTap: () {
                              _getUserLocation();
                            },
                            onTapDown: (_) {
                              setState(() {
                                _isPressed = true;
                              });
                            },
                            onTapUp: (_) {
                              setState(() {
                                _isPressed = false;
                              });
                            },
                            onTapCancel: () {
                              setState(() {
                                _isPressed = false;
                              });
                            },
                            child: AnimatedScale(
                              scale: _isPressed ? 0.95 : 1.0,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                width: 130,
                                height: 130,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: checkIn
                                      ? const Color(0xFFEF5350)
                                      : const Color(0xFFFBB040),
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.touch_app,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      checkIn ? 'تسجيل الخروج' : 'تسجيل الدخول',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              Icons.access_time_outlined,
                              checkOutToday != null
                                  ? "${duration!.inHours.toString().padLeft(2, '0')}:${duration!.inMinutes.toString().padLeft(2, '0')}"
                                  : "--:--",
                              ' ساعات اليوم',
                              Colors.black,
                            ),
                            _buildStatItem(
                              Icons.access_time_outlined,
                              checkOutToday != null
                                  ? "${checkOutToday!.hour.toString().padLeft(2, '0')}:${checkOutToday!.minute.toString().padLeft(2, '0')}"
                                  : "--:--",
                              ' تسجيل الخروج',
                              Colors.black,
                            ),
                            _buildStatItem(
                              Icons.access_time_outlined,
                              checkInToday != null
                                  ? "${checkInToday!.hour.toString().padLeft(2, '0')}:${checkInToday!.minute.toString().padLeft(2, '0')}"
                                  : "--:--",
                              ' تسجيل الدخول',
                              Colors.black,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String time, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 28, color: iconColor),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}
