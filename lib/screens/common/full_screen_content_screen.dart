import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum ContentType { image, video, youtube }

class FullScreenContentScreen extends StatelessWidget {
  final String contentUrl;
  final ContentType type;

  const FullScreenContentScreen({
    super.key,
    required this.contentUrl,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (type) {
      case ContentType.image:
        return Center(
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(contentUrl),
            loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text("Error loading image", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      case ContentType.video:
      case ContentType.youtube:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline, color: Colors.white, size: 64),
              const SizedBox(height: 20),
              const Text(
                "Video Playback",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  type == ContentType.youtube ? "YouTube playback is coming soon." : "Video playback is coming soon.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE"),
              ),
            ],
          ),
        );
    }
  }
}
