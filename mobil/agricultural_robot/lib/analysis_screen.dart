// lib/analysis_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'camera_screen.dart';
import 'controls_screen.dart';

// --- PlaceholderScreen Tanımı (Eğer başka yerde tanımlı değilse) ---
// Diğer sekmeler için geçici yer tutucu widget.
// İstersen bunu ayrı bir dosyaya da taşıyabilirsin.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title Sayfası',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _currentNavIndex = 1; // Analysis tab selected

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF1B5E20) : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle(context, 'Plant Analysis', titleColor),
          const SizedBox(height: 12),
          _buildAnalysisCard(
            context,
            cardColor: cardColor,
            icon: Icons.eco,
            iconColor: Colors.lightGreen,
            title: 'General Health Condition',
            value: 'Good',
            description: 'Plant appears to be in good health overall.',
            textColor: textColor,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            context,
            cardColor: cardColor,
            icon: Icons.thermostat,
            iconColor: Colors.orange,
            title: 'Ambient Conditions',
            value: 'Ideal Level',
            description:
                'Temperature and humidity have been stable for the last 24 hours.',
            textColor: textColor,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            context,
            cardColor: cardColor,
            icon: Icons.water_drop,
            iconColor: Colors.blue,
            title: 'Soil Moisture Analysis',
            value: '65% Average',
            description:
                'Moisture level is within suitable range for tomatoes.',
            textColor: textColor,
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            context,
            cardColor: cardColor,
            icon: Icons.bug_report,
            iconColor: Colors.redAccent,
            title: 'Disease/Pest Detection',
            value: 'No Signs',
            description: 'No abnormalities detected in recent scans.',
            textColor: textColor,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Suggestions', titleColor),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            context,
            cardColor: cardColor,
            icon: Icons.lightbulb_outline,
            text: 'Continue monitoring sunlight exposure time.',
            textColor: textColor,
          ),
          const SizedBox(height: 10),
          _buildRecommendationCard(
            context,
            cardColor: cardColor,
            icon: Icons.water_damage_outlined,
            text: 'Irrigate when soil moisture drops below 55%.',
            textColor: textColor,
          ),
        ],
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
            } else if (index == 2) {
              // Camera tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            } else if (index == 3) {
              // Controls tab
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ControlsScreen()),
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

  // Analiz ekranına özel build metotları (önceki cevapla aynı)
  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
    );
  }

  Widget _buildAnalysisCard(
    BuildContext context, {
    required Color cardColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String description,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor.withOpacity(0.9),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required Color cardColor,
    required IconData icon,
    required String text,
    required Color textColor,
  }) {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
