import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class InterfacePage extends StatefulWidget {
  const InterfacePage({super.key});

  @override
  State<InterfacePage> createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  int _selectedIndex = 0;

  // List of pages to navigate
  final List<Widget> pages = [
    const HomePage(),
    const ProfilePage(),
    const SettingsPage(),
  ];

  // Titles corresponding to each page
  final List<String> _titles = [
    'Study Timer',
    'Profile',
    'Settings',
  ];

  // List to store notifications
  List<String> notifications = [];

  // Handle tap event to change selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Add a notification to the list
  void addNotification(String message) {
    setState(() {
      notifications.add(message);
    });
  }

  // Logout function to clear preferences and exit the app

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: pages[_selectedIndex], // Display selected page here
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}
