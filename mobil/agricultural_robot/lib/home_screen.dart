import 'package:flutter/material.dart';
import 'dart:async';
import 'analysis_screen.dart';
import 'camera_screen.dart';
import 'controls_screen.dart';
import 'widgets/status_bar.dart';
import 'widgets/plant_health_card.dart';
import 'widgets/sensor_cards.dart';
import 'widgets/alerts_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  // System status variables
  DateTime _lastUpdate = DateTime.now(); // Last data refresh timestamp
  final bool _isOnline = true; // System connection status

  // Plant health metrics
  final int _healthPercentage = 89; // Overall plant health percentage
  //final String _healthStatus = "Healthy"; // Current health status text //BURAYI BEN YORUMA ALDIM KULALNILMADIĞI İÇİN

  // Environmental sensor data
  final double _soilMoisture = 73.6; // Soil moisture percentage
  final double _temperature = 44.5; // Air temperature in Celsius
  final double _humidity = 58.0; // Air humidity percentage

  // Irrigation system data
  final String _irrigationStatus = "Inactive"; // Current irrigation status
  final String _lastIrrigation = "3 hours ago"; // Time since last irrigation
  final String _lastImageTime = "Today 14:35"; // Timestamp of last plant image

  // Alert system data
  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'info',
      'message': 'Ideal temperature for photosynthesis',
      'time': '',
    },
    {'type': 'warning', 'message': 'Soil moisture is decreasing', 'time': ''},
  ];

  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    // In a real application, start data streaming here
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  void _refreshData() {
    // In a real application, API calls or database queries would go here
    setState(() {
      _lastUpdate = DateTime.now();
      // Update other data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Agricultural Tracking Robot",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6, color: Colors.white),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          return Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              StatusBar(
                lastUpdate: _lastUpdate,
                isOnline: _isOnline,
              ),
              const SizedBox(height: 8),
              PlantHealthCard(
                healthPercentage: _healthPercentage,
                lastImageTime: _lastImageTime,
              ),
              const SizedBox(height: 12),
              SensorCards(
                soilMoisture: _soilMoisture,
                temperature: _temperature,
                humidity: _humidity,
                irrigationStatus: _irrigationStatus,
                lastIrrigation: _lastIrrigation,
                lastUpdate: _lastUpdate,
              ),
              const SizedBox(height: 12),
              AlertsCard(alerts: _alerts),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
            if (index == 1) {
              // Analysis tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnalysisScreen(),
                  maintainState: true,
                ),
              ).then((_) {
                setState(() {
                  _currentNavIndex = 0;
                });
              });
            } else if (index == 2) {
              // Camera tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                  maintainState: true,
                ),
              ).then((_) {
                setState(() {
                  _currentNavIndex = 0;
                });
              });
            } else if (index == 3) {
              // Controls tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ControlsScreen(),
                  maintainState: true,
                ),
              ).then((_) {
                setState(() {
                  _currentNavIndex = 0;
                });
              });
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
}
