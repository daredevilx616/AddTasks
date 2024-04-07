import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final Map<String, bool> expandedTiles = {};
  bool expandAll = false;

  void _toggleExpandAll() {
    setState(() {
      expandAll = !expandAll; // Toggle expand all state
      // Set all values in the map to the toggled state
      expandedTiles.updateAll((key, value) => expandAll);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks'),
        actions: [
          IconButton(
            icon: Icon(expandAll ? Icons.expand_less : Icons.expand_more),
            onPressed: _toggleExpandAll,
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestore
            .collection('tasks')
            .where('userId', isEqualTo: user!.uid)
            .orderBy('day')
            .orderBy('startTime')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No tasks found.'));
          }

          Map<String, Map<String, List<Map<String, dynamic>>>> groupedTasks =
              {};
          for (var doc in snapshot.data!.docs) {
            var task = doc.data() as Map<String, dynamic>;
            task['id'] = doc.id;
            String day = task['day'];
            String timeFrame = '${task['startTime']} - ${task['endTime']}';
            expandedTiles[day] ??=
                expandAll; // Initialize with the state of expand all
            expandedTiles[timeFrame] ??=
                expandAll; // Initialize time frames too
            if (groupedTasks[day] == null) groupedTasks[day] = {};
            if (groupedTasks[day]![timeFrame] == null) {
              groupedTasks[day]![timeFrame] = [];
            }
            groupedTasks[day]![timeFrame]!.add(task);
          }

          List<Widget> dayWidgets = groupedTasks.entries.map((dayEntry) {
            List<Widget> timeFrameWidgets =
                dayEntry.value.entries.map((timeFrameEntry) {
              return ExpansionTile(
                key: PageStorageKey<String>(
                    timeFrameEntry.key), // Unique key for preserving state
                initiallyExpanded: expandedTiles[timeFrameEntry.key]!,
                title: Text(timeFrameEntry.key),
                children: timeFrameEntry.value.map((task) {
                  return ListTile(
                    title: Text(task['name']),
                    leading: Checkbox(
                      value: task['completed'],
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          firestore.collection('tasks').doc(task['id']).update(
                              {'completed': newValue}).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Failed to update task'),
                            ));
                          });
                        }
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        firestore
                            .collection('tasks')
                            .doc(task['id'])
                            .delete()
                            .catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to delete task'),
                          ));
                        });
                      },
                    ),
                  );
                }).toList(),
              );
            }).toList();

            return ExpansionTile(
              key: PageStorageKey<String>(
                  dayEntry.key), // Unique key for preserving state
              initiallyExpanded: expandedTiles[dayEntry.key]!,
              onExpansionChanged: (bool expanded) {
                setState(() {
                  expandedTiles[dayEntry.key] = expanded;
                });
              },
              title: Text(dayEntry.key),
              children: timeFrameWidgets,
            );
          }).toList();

          return ListView(
            children: dayWidgets,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
      ),
    );
  }
}
