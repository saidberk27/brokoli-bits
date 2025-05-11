import 'package:flutter/material.dart';

class PlantHealthCard extends StatelessWidget {
  final int healthPercentage;
  final String lastImageTime;

  const PlantHealthCard({
    Key? key,
    required this.healthPercentage,
    required this.lastImageTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildHealthIndicator(),
              const SizedBox(width: 16),
              _buildPlantImage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: healthPercentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getHealthColor(healthPercentage),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$healthPercentage%",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Health",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getHealthMessage(healthPercentage),
          style: TextStyle(
            color: _getHealthColor(healthPercentage),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlantImage() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Last Image: $lastImageTime",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.photo_camera, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(int percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getHealthMessage(int percentage) {
    if (percentage >= 70) return "Healthy";
    if (percentage >= 40) return "Monitor";
    return "Attention!";
  }
}
