import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _universityLevel;
  String? _program;
  String? _about;
  dynamic _image; // Dynamic for both File and web image support
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name');
      _universityLevel = prefs.getString('universityLevel');
      _program = prefs.getString('program');
      _about = prefs.getString('about');
      String? imagePath = prefs.getString('image');
      if (imagePath != null) {
        if (kIsWeb) {
          _image = imagePath;
        } else {
          _image = File(imagePath);
        }
      }
    });
  }

  // Save profile data to SharedPreferences
  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', _name ?? '');
    prefs.setString('universityLevel', _universityLevel ?? '');
    prefs.setString('program', _program ?? '');
    prefs.setString('about', _about ?? '');
    if (_image != null) {
      prefs.setString('image', _image is File ? _image.path : _image);
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        final base64Image = 'data:image/png;base64,${base64Encode(bytes)}';
        setState(() {
          _image = base64Image;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
      _saveProfileData();
    }
  }

  // Show dialog to edit profile fields
  Future<void> _editProfile() async {
    TextEditingController nameController = TextEditingController(text: _name);
    TextEditingController universityLevelController =
        TextEditingController(text: _universityLevel);
    TextEditingController programController =
        TextEditingController(text: _program);
    TextEditingController aboutController = TextEditingController(text: _about);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                    nameController, 'Name', (value) => _name = value),
                _buildTextField(universityLevelController, 'University Level',
                    (value) => _universityLevel = value),
                _buildTextField(
                    programController, 'Program', (value) => _program = value),
                _buildTextField(
                    aboutController, 'About', (value) => _about = value),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text;
                  _universityLevel = universityLevelController.text;
                  _program = programController.text;
                  _about = aboutController.text;
                });
                _saveProfileData();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      ValueChanged<String> onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _buildProfileDetail(String label, String? value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Colors.orange),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'Not set',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile image with edit functionality
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: _image != null
                          ? (kIsWeb
                              ? NetworkImage(_image)
                              : FileImage(_image as File)) as ImageProvider
                          : null,
                      child: _image == null
                          ? const Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Updated profile details
                _buildProfileDetail('Name', _name, Icons.person),
                _buildProfileDetail(
                    'University Level', _universityLevel, Icons.school),
                _buildProfileDetail('Program', _program, Icons.book),
                _buildProfileDetail('About', _about, Icons.info),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: _editProfile,
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
