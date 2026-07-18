import 'package:flutter/material.dart';

// Opens a photo full-screen, pinch-to-zoom, tap the backdrop or the close
// button to dismiss. The one place a review photo or a portfolio photo
// opens up to, instead of just a thumbnail with nowhere to go.
void openPhoto(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: _PhotoViewerPage(url: url),
      ),
    ),
  );
}

class _PhotoViewerPage extends StatelessWidget {
  const _PhotoViewerPage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: InteractiveViewer(
                child: Center(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
