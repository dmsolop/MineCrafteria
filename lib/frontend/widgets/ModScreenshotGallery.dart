import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../backend/AccessKeys.dart';

class ModScreenshotGallery extends StatefulWidget {
  final List<String> screenshots;

  const ModScreenshotGallery({super.key, required this.screenshots});

  @override
  State<ModScreenshotGallery> createState() => _ModScreenshotGalleryState();
}

class _ModScreenshotGalleryState extends State<ModScreenshotGallery> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.screenshots.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.screenshots[index],
                  headers: {
                    "CF-Access-Client-Secret": AccessKeys.client_secret,
                    "CF-Access-Client-Id": AccessKeys.client_id,
                  },
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.screenshots.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 8,
            dotColor: Colors.white38,
            activeDotColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
