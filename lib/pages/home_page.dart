import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Course> courses = [];
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Timer _timer;
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _initializeNotifications();
    _loadNotifications();
  }

  void _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS (Darwin) Initialization (updated for version 18)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS:
          initializationSettingsIOS, // Use DarwinInitializationSettings for iOS
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void requestIOSPermission() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _showNotification(String courseTitle) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'course_channel_id',
      'Course Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Course Added',
      'You added $courseTitle',
      notificationDetails,
    );

    _addNotification('You added $courseTitle');
  }

  void _addNotification(String message) {
    setState(() {
      notifications.add(message);
    });
    _saveNotifications();
  }

  void _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedNotifications = prefs.getString('notifications');
    if (savedNotifications != null) {
      setState(() {
        notifications = List<String>.from(json.decode(savedNotifications));
      });
    }
  }

  void _saveNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('notifications', json.encode(notifications));
  }

  void _loadCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCourses = prefs.getString('courses');
    if (savedCourses != null) {
      List<dynamic> decodedCourses = json.decode(savedCourses);
      setState(() {
        courses.addAll(
            decodedCourses.map((course) => Course.fromJson(course)).toList());
      });
      _startTimers();
    }
  }

  void _saveCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedCourses =
        json.encode(courses.map((course) => course.toJson()).toList());
    prefs.setString('courses', encodedCourses);
  }

  void _editCourse(int index, Course course) {
    TextEditingController courseTitleController =
        TextEditingController(text: course.title);
    TextEditingController courseCodeController =
        TextEditingController(text: course.code);
    TextEditingController timeToStudyController =
        TextEditingController(text: course.timeToStudy);
    TextEditingController dateController =
        TextEditingController(text: course.date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: courseTitleController,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                ),
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  controller: timeToStudyController,
                  decoration:
                      const InputDecoration(labelText: 'Select Time to Study'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeToStudyController.text = pickedTime.format(context);
                    }
                  },
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Select Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (courseTitleController.text.isNotEmpty &&
                    courseCodeController.text.isNotEmpty &&
                    timeToStudyController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  setState(() {
                    courses[index] = Course(
                      title: courseTitleController.text,
                      code: courseCodeController.text,
                      timeToStudy: timeToStudyController.text,
                      date: dateController.text,
                      targetDateTime: _getTargetDateTime(
                        dateController.text,
                        timeToStudyController.text,
                      ),
                    );
                    _saveCourses();
                    scheduleAlarm(courses[index].targetDateTime);
                    _showNotification(courseTitleController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Changes"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _addCourse() {
    TextEditingController courseTitleController = TextEditingController();
    TextEditingController courseCodeController = TextEditingController();
    TextEditingController timeToStudyController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Course'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: courseTitleController,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                ),
                TextField(
                  controller: courseCodeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                TextField(
                  controller: timeToStudyController,
                  decoration:
                      const InputDecoration(labelText: 'Select Time to Study'),
                  readOnly: true,
                  onTap: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      timeToStudyController.text = pickedTime.format(context);
                    }
                  },
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Select Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (courseTitleController.text.isNotEmpty &&
                    courseCodeController.text.isNotEmpty &&
                    timeToStudyController.text.isNotEmpty &&
                    dateController.text.isNotEmpty) {
                  setState(() {
                    final newCourse = Course(
                      title: courseTitleController.text,
                      code: courseCodeController.text,
                      timeToStudy: timeToStudyController.text,
                      date: dateController.text,
                      targetDateTime: _getTargetDateTime(
                        dateController.text,
                        timeToStudyController.text,
                      ),
                    );
                    courses.add(newCourse);
                    _saveCourses();
                    scheduleAlarm(newCourse.targetDateTime);
                    _showNotification(courseTitleController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Course"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  DateTime _getTargetDateTime(String date, String timeToStudy) {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateFormat timeFormat = DateFormat("HH:mm"); // 24-hour format (no AM/PM)
    DateTime dateTime = dateFormat.parse(date);
    DateTime time = timeFormat.parse(timeToStudy);
    return DateTime(
        dateTime.year, dateTime.month, dateTime.day, time.hour, time.minute);
  }

  String _getTimeRemaining(DateTime targetDateTime) {
    Duration difference = targetDateTime.difference(DateTime.now());
    if (difference.isNegative) return "Time's up!";
    int hours = difference.inHours;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;
    return "${hours}h ${minutes}m ${seconds}s";
  }

  void _startTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              title: Text(course.title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code: ${course.code}',
                      style: const TextStyle(color: Colors.blue)),
                  Text('Time to Study: ${course.timeToStudy}',
                      style: const TextStyle(color: Colors.orange)),
                  Text('Date: ${course.date}',
                      style: const TextStyle(color: Colors.green)),
                  Text(
                      'Remaining Time: ${_getTimeRemaining(course.targetDateTime)}',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _editCourse(index, course),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          shadows: [BoxShadow(color: Colors.black)],
        ),
      ),
    );
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void scheduleAlarm(DateTime targetDateTime) async {
  // Convert the targetDateTime to TZDateTime
  final scheduledDate = tz.TZDateTime.from(targetDateTime, tz.local);

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Reminder',
    'Study for your course!',
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'course_channel_id',
        'Course Notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode
        .exactAllowWhileIdle, // Pass androidScheduleMode directly here
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents:
        DateTimeComponents.time, // Optional for repeating notifications
  );
}

class IOSInitializationSettings {}

class Course {
  final String title;
  final String code;
  final String timeToStudy;
  final String date;
  final DateTime targetDateTime;

  Course({
    required this.title,
    required this.code,
    required this.timeToStudy,
    required this.date,
    required this.targetDateTime,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      title: json['title'],
      code: json['code'],
      timeToStudy: json['timeToStudy'],
      date: json['date'],
      targetDateTime: DateTime.parse(json['targetDateTime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'code': code,
      'timeToStudy': timeToStudy,
      'date': date,
      'targetDateTime': targetDateTime.toIso8601String(),
    };
  }
}
