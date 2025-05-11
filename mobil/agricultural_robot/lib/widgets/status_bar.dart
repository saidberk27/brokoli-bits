import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final DateTime lastUpdate;
  final bool isOnline;

  const StatusBar({
    Key? key,
    required this.lastUpdate,
    required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Card(
        color: const Color(0xFFE8F5E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: isOnline ? const Color(0xFF1B5E20) : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? "System Online" : "System Offline",
                style: TextStyle(
                  color: isOnline ? const Color(0xFF1B5E20) : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "Last Updated: ${_formatTime(lastUpdate)}",
                style: const TextStyle(color: Color(0xFF1B5E20), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
