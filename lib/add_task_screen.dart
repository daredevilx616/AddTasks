import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _taskNameController = TextEditingController();
  String? _selectedDay;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future addTask() async {
    if (_taskNameController.text.isEmpty ||
        _selectedDay == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all the fields'),
      ));
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('tasks').add({
        'name': _taskNameController.text.trim(),
        'day': _selectedDay,
        'startTime': _startTime!.format(context),
        'endTime': _endTime!.format(context),
        'completed': false,
        'userId': user!.uid,
      });
      Navigator.of(context).pop(); // Go back to the previous screen
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add the task'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            DropdownButton<String>(
              value: _selectedDay,
              hint: Text('Select Day'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDay = newValue;
                });
              },
              items: _daysOfWeek.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                        'Start Time: ${_startTime?.format(context) ?? 'Not set'}'),
                    onTap: () => _pickTime(context, true),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                        'End Time: ${_endTime?.format(context) ?? 'Not set'}'),
                    onTap: () => _pickTime(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addTask,
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
