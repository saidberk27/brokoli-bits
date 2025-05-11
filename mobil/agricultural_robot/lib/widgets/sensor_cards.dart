import 'package:flutter/material.dart';

class SensorCards extends StatefulWidget {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final String irrigationStatus;
  final String lastIrrigation;
  final DateTime lastUpdate;

  const SensorCards({
    Key? key,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.irrigationStatus,
    required this.lastIrrigation,
    required this.lastUpdate,
  }) : super(key: key);

  @override
  State<SensorCards> createState() => _SensorCardsState();
}

class _SensorCardsState extends State<SensorCards> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          _buildSoilMoistureCard(),
          _buildTemperatureHumidityCard(),
          _buildIrrigationCard(),
        ],
      ),
    );
  }

  Widget _buildSoilMoistureCard() {
    return _buildSensorCard(
      icon: Icons.water_drop,
      title: "Soil Moisture",
      value: "${widget.soilMoisture}%",
      color: _getMoistureColor(widget.soilMoisture),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: widget.soilMoisture / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getMoistureColor(widget.soilMoisture),
                ),
              ),
            ),
            Text(
              "${widget.soilMoisture}%",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      footer: "Last Updated: ${_formatTime(widget.lastUpdate)}",
    );
  }

  Widget _buildTemperatureHumidityCard() {
    return _buildSensorCard(
      icon: Icons.thermostat,
      title: "Air Conditions",
      value: "${widget.temperature}°C",
      color: _getTemperatureColor(widget.temperature),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.thermostat, size: 20),
              const SizedBox(width: 4),
              Text(
                "${widget.temperature}°C",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_drop_outlined, size: 20),
              const SizedBox(width: 4),
              Text(
                "${widget.humidity}%",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      footer: "DHT11 Sensor",
    );
  }

  Widget _buildIrrigationCard() {
    return _buildSensorCard(
      icon: Icons.add,
      title: "Irrigation",
      value: widget.irrigationStatus,
      color: widget.irrigationStatus == "Active" ? Colors.blue : Colors.grey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.irrigationStatus == "Active"
                ? Icons.water
                : Icons.water_drop_outlined,
            size: 40,
            color:
                widget.irrigationStatus == "Active" ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            widget.irrigationStatus,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.irrigationStatus == "Active"
                  ? Colors.blue
                  : Colors.grey,
            ),
          ),
        ],
      ),
      footer: "Last irrigation: ${widget.lastIrrigation}",
      action: FloatingActionButton.small(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.play_arrow, size: 20),
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Widget child,
    required String footer,
    Widget? action,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w500, color: color),
                  ),
                ],
              ),
              const Spacer(),
              child,
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      footer,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  if (action != null) action,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMoistureColor(double percentage) {
    if (percentage < 30) return Colors.red; // Very dry
    if (percentage < 50) return Colors.orange; // Dry
    if (percentage < 70) return Colors.green; // Ideal
    if (percentage < 85) return Colors.lightBlue; // Moist
    return Colors.blue; // Very moist
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue; // Cold
    if (temp < 22) return Colors.green; // Ideal
    if (temp < 28) return Colors.orange; // Hot
    return Colors.red; // Very hot
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
