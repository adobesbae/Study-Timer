import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_timer/settings/help_and_support.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  dynamic _image;
  String? _name;
  String? _universityLevel;
  String? _program;
  String? _about;

  final ImagePicker _picker = ImagePicker();

  TextEditingController nameController = TextEditingController();
  TextEditingController universityLevelController = TextEditingController();
  TextEditingController programController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _name = prefs.getString('name') ?? '';
      _universityLevel = prefs.getString('universityLevel') ?? '';
      _program = prefs.getString('program') ?? '';
      _about = prefs.getString('about') ?? '';

      String? imagePath = prefs.getString('image');
      if (imagePath != null && imagePath.isNotEmpty) {
        _image = File(imagePath);
      }

      nameController.text = _name!;
      universityLevelController.text = _universityLevel!;
      programController.text = _program!;
      aboutController.text = _about!;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name ?? '');
    prefs.setString('universityLevel', _universityLevel ?? '');
    prefs.setString('program', _program ?? '');
    prefs.setString('about', _about ?? '');

    if (_image != null && _image is File) {
      prefs.setString('image', (_image as File).path);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null
                      ? FileImage(_image as File)
                      : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: nameController,
              labelText: 'Name',
              onChanged: (value) => _name = value,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: universityLevelController,
              labelText: 'University Level',
              onChanged: (value) => _universityLevel = value,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: programController,
              labelText: 'Program', 
              onChanged: (value) => _program = value,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: aboutController,
              labelText: 'About',
              onChanged: (value) => _about = value,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _saveSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings Saved")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save Settings",
              style: TextStyle(
                color: Colors.black,
              ),),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.help, color: Colors.white,),
              title: const Text('Help & Support',
              style: TextStyle(
                color: Colors.white
              ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpAndSupport()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,

  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        style: TextStyle(color: Colors.white),
        controller: controller,
        decoration: InputDecoration(labelText: labelText, labelStyle: TextStyle(
          color: Colors.white
        ),
      ),
        onChanged: onChanged,
      ),
    );
  }
}
