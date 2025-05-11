import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'analysis_screen.dart';
import 'camera_screen.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({Key? key}) : super(key: key);

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  bool _isIrrigationActive = false;
  int _selectedDuration = 5; // minutes
  DateTime _selectedDateTime = DateTime.now();
  String _repeatOption = 'One Time';
  final List<Map<String, dynamic>> _scheduledTasks = [];
  int _currentNavIndex = 3; // Controls tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controls'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIrrigationControlPanel(),
            const SizedBox(height: 24),
            _buildTaskPlanner(),
            const SizedBox(height: 24),
            _buildStatusCards(),
            const SizedBox(height: 24),
            _buildSmartSettings(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
            if (index == 0) {
              // Home tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    toggleTheme: () {
                      // Theme toggle functionality will be handled by the HomeScreen
                    },
                  ),
                ),
              );
            } else if (index == 1) {
              // Analysis tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AnalysisScreen()),
              );
            } else if (index == 2) {
              // Camera tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: Colors.grey,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Analysis"),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: "Controls"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }

  Widget _buildIrrigationControlPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Real-time Irrigation Control Panel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isIrrigationActive = !_isIrrigationActive;
                      });
                    },
                    icon: Icon(
                      _isIrrigationActive ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    label: Text(
                      _isIrrigationActive
                          ? 'Stop Irrigation'
                          : 'Start Irrigation',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isIrrigationActive ? Colors.red : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(),
                    ),
                    items: [5, 10, 15, 20, 30].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value minutes'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedDuration = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskPlanner() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Planner',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(_selectedDateTime),
                        );
                        if (time != null) {
                          setState(() {
                            _selectedDateTime = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      '${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _repeatOption,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: ['One Time', 'Daily', 'Weekly', 'Monthly']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _repeatOption = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _scheduledTasks.add({
                    'dateTime': _selectedDateTime,
                    'repeat': _repeatOption,
                    'duration': _selectedDuration,
                  });
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            if (_scheduledTasks.isNotEmpty) ...[
              const Text(
                'Scheduled Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _scheduledTasks.length,
                itemBuilder: (context, index) {
                  final task = _scheduledTasks[index];
                  return ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(
                      '${task['dateTime'].day}/${task['dateTime'].month}/${task['dateTime'].year} ${task['dateTime'].hour}:${task['dateTime'].minute.toString().padLeft(2, '0')}',
                    ),
                    subtitle:
                        Text('${task['repeat']} - ${task['duration']} minutes'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _scheduledTasks.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Irrigation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3 hours ago',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '15 minutes',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tomorrow 08:00',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Daily',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Automatic Irrigation'),
              subtitle: const Text('Irrigate based on moisture level'),
              value: true,
              onChanged: (bool value) {
                // Implement auto irrigation logic
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Night Mode'),
              subtitle: const Text('Optimize night irrigation'),
              value: false,
              onChanged: (bool value) {
                // Implement night mode logic
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Weather Integration'),
              subtitle: const Text('Irrigate based on rain forecasts'),
              value: true,
              onChanged: (bool value) {
                // Implement weather integration logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
