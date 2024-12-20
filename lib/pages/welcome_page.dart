import 'package:flutter/material.dart';
import 'package:study_timer/pages/interface_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            const Text(
              'Study Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Times in new roman',
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Track study sessions daily',
              style: TextStyle(color: Colors.white),
            ),
            Image.asset(
              'assets/images/logo.png',
              scale: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InterfacePage(),
                  ),
                );
              },
              child: const Text(
                "Proceed",
                style: TextStyle(color: Colors.black),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.timelapse,
              color: Colors.white,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
