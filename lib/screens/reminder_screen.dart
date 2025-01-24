import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_cast/services/api_service.dart';
import 'package:weather_cast/services/reminder_service.dart';

class RemindersScreen extends StatefulWidget {
  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  List<dynamic> _reminders = [];
  ReminderService _reminderService = ReminderService();

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // Load all reminders
  _loadReminders() async {
    try {
      final reminders = await _reminderService.fetchReminders();
      setState(() {
        _reminders = reminders;
      });
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  // Show dialog to add or edit a reminder
  _showReminderDialog([dynamic reminder]) async {
    String title = reminder != null ? reminder['title'] : '';
    String description = reminder != null ? reminder['description'] : '';
    DateTime? selectedDateTime =
        reminder != null ? DateTime.parse(reminder['time']) : null;

    // Date and Time values
    DateTime? selectedDate = selectedDateTime ?? DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(reminder != null ? 'Edit Reminder' : 'Add Reminder'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: TextEditingController(text: title),
                    decoration: InputDecoration(hintText: 'Reminder Title'),
                    onChanged: (value) => title = value,
                  ),
                  TextField(
                    controller: TextEditingController(text: description),
                    decoration: InputDecoration(hintText: 'Description'),
                    onChanged: (value) => description = value,
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      // Show Date Picker
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                          selectedDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate!),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      // Show Time Picker
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null) {
                        setDialogState(() {
                          selectedTime = pickedTime;
                          selectedDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text(
                          selectedDateTime != null
                              ? DateFormat('HH:mm').format(selectedDateTime!)
                              : 'Select Time',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (title.isNotEmpty && selectedDateTime != null) {
                      try {
                        // Create or update reminder
                        if (reminder == null) {
                          await _reminderService.createReminder(
                              title, description, selectedDateTime.toString());
                          _showSuccessSnackbar(
                              'Reminder created successfully!');
                        } else {
                          await _reminderService.updateReminder(reminder['id'],
                              title, description, selectedDateTime.toString());
                          _showSuccessSnackbar(
                              'Reminder updated successfully!');
                        }
                        _loadReminders(); // Reload reminders after adding/editing
                        Navigator.pop(context);
                      } catch (error) {
                        // Handle error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error')),
                        );
                      }
                    }
                    // else {
                    //   // Show error if title or date is empty
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //         content:
                    //             Text('Please fill in the title and date.')),
                    //   );
                    // }
                  },
                  child: Text(reminder != null ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete a reminder
  _deleteReminder(String id) async {
    try {
      await _reminderService.deleteReminder(id);
      _loadReminders(); // Reload the reminders after deleting
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showReminderDialog(),
          ),
        ],
      ),
      body: _reminders.isEmpty
          ? Center(
              child: Text('Add weather reminders',
                  style: TextStyle(fontSize: 18, color: Colors.grey)))
          //     ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                DateTime reminderTime = DateTime.parse(reminder['time']);
                return ListTile(
                  title: Text(reminder['title']),
                  subtitle: Text(
                    // ${reminder['description']}\n
                    '${DateFormat('yyyy-MM-dd HH:mm').format(reminderTime)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteFromDialog(context, reminder['id']);
                    },
                  ),
                  onTap: () {
                    _showReminderDialog(reminder);
                  },
                );
              },
            ),
    );
  }

  _deleteFromDialog(BuildContext context, reminder) {
    return showDialog(
        context: context,
        builder: (parm) {
          return AlertDialog(
            title: const Text(
              'Delete this reminder?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      // foregroundColor: Colors.blueGrey,
                      //backgroundColor: Colors.blueGrey,
                      ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(fontSize: 17))),
              TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    //backgroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    _deleteReminder(reminder);
                    Navigator.pop(context);
                    _showSuccessSnackbar('Reminder deleted successfully');
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 17),
                  )),
            ],
          );
        });
  }

  _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
