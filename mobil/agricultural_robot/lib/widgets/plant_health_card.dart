import 'package:flutter/material.dart';
import 'mjpeg_stream.dart';

class PlantHealthCard extends StatefulWidget {
  final int healthPercentage;
  final String lastImageTime;

  const PlantHealthCard({
    Key? key,
    required this.healthPercentage,
    required this.lastImageTime,
  }) : super(key: key);

  @override
  State<PlantHealthCard> createState() => _PlantHealthCardState();
}

class _PlantHealthCardState extends State<PlantHealthCard> {
  late TextEditingController _controller;
  String _currentStreamUrl = 'http://192.168.7.252:8000/video_feed';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _currentStreamUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateStreamUrl() {
    setState(() {
      _currentStreamUrl = _controller.text.trim();
    });
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sağlık göstergesi (%40)
              Flexible(
                flex: 4,
                child: _buildHealthIndicator(),
              ),
              const SizedBox(width: 16),
              // Kamera görüntüsü ve altındaki adres girişi (%60)
              Flexible(
                flex: 6,
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: MjpegStreamWidget(
                        streamUrl: _currentStreamUrl,
                        width: 640,
                        height: 480,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              labelText: 'Kamera Akış Adresi',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _updateStreamUrl,
                          child: const Text('Güncelle'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Son Görüntü: ${widget.lastImageTime}"),
                    ),
                  ],
                ),
              ),
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
                  value: widget.healthPercentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getHealthColor(widget.healthPercentage),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.healthPercentage}%",
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
          _getHealthMessage(widget.healthPercentage),
          style: TextStyle(
            color: _getHealthColor(widget.healthPercentage),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
