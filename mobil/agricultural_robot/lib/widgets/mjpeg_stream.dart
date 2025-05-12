// mjpeg_stream.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Web için gerekli importlar:
/// ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;
import 'dart:html' as html;

class MjpegStreamWidget extends StatelessWidget {
  final String streamUrl;
  final double width;
  final double height;

  const MjpegStreamWidget({
    Key? key,
    required this.streamUrl,
    this.width = 640,
    this.height = 480,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        streamUrl,
        (int viewId) => html.ImageElement()
          ..src = streamUrl
          ..width = width.toInt()
          ..height = height.toInt()
          ..style.border = '2px solid #555',
      );
      return SizedBox(
        width: width,
        height: height,
        child: HtmlElementView(viewType: streamUrl),
      );
    } else {
      // Mobil ve desktop için
      return Image.network(
        streamUrl,
        width: width,
        height: height,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            "Akışa bağlanılamadı: $error",
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }
}
