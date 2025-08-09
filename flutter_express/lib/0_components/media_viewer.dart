import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaViewer extends StatelessWidget {
  final String filePath;
  final double scale;

  const MediaViewer({Key? key, required this.filePath, required this.scale})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filePath.isEmpty) {
      return _NoMatchFound();
    } else if (filePath.toLowerCase().endsWith('.mp4') ||
        filePath.toLowerCase().endsWith('.mov')) {
      return _VideoPlayerWidget(filePath: filePath);
    } else if (filePath.toLowerCase().endsWith('.png') ||
        filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg')) {
      return _ImageViewer(filePath: filePath);
    } else {
      return _NoMatchFound();
    }
  }
}

class _NoMatchFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No Match Found or Unsupported Media',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            // Removed Feedback or Search button and dialog
          ],
        ),
      ),
    );
  }
}

class _ImageViewer extends StatelessWidget {
  final String filePath;

  const _ImageViewer({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        // Use SizedBox to give explicit dimensions to the image container
        width: 300,
        height: 300,
        child: filePath.startsWith('http') || filePath.startsWith('https')
            ? Image.network(
                filePath,
                fit: BoxFit
                    .contain, // Fit the image within the SizedBox, maintaining aspect ratio
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  );
                },
              )
            : Image.asset(
                filePath,
                fit: BoxFit
                    .contain, // Fit the image within the SizedBox, maintaining aspect ratio
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100, color: Colors.grey);
                },
              ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String filePath;

  const _VideoPlayerWidget({Key? key, required this.filePath})
    : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 1.0, 1.5, 2.0];

  final double displayWidth = 300; // Fixed width for video player
  final double progressBarThickness = 20.0;
  final double circleDiameter = 20.0;

  @override
  void initState() {
    super.initState();
    if (widget.filePath.startsWith('http') ||
        widget.filePath.startsWith('https')) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.filePath),
      );
    } else {
      _controller = VideoPlayerController.asset(widget.filePath);
    }

    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {});
          }
        })
        .catchError((error) {
          print("Error initializing video: $error");
          if (mounted) {
            // Optionally display an error message on the UI
            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load video')));
          }
        });

    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 200,
          child: const CircularProgressIndicator(),
        ),
      );
    }

    final double videoWidth = MediaQuery.of(context).size.width * 0.9;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: videoWidth, // 90% of screen width
            ),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        _CustomProgressBar(
          controller: _controller,
          width: videoWidth, // match video width
          height: progressBarThickness,
          circleDiameter: circleDiameter,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
            ),
            DropdownButton<double>(
              value: _playbackSpeed,
              items: _speedOptions.map((double speed) {
                return DropdownMenuItem<double>(
                  value: speed,
                  child: Text('${speed}x'),
                );
              }).toList(),
              onChanged: (double? newSpeed) {
                if (newSpeed != null) {
                  setState(() {
                    _playbackSpeed = newSpeed;
                    _controller.setPlaybackSpeed(_playbackSpeed);
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final VideoPlayerController controller;
  final double width;
  final double height;
  final double circleDiameter;

  const _CustomProgressBar({
    Key? key,
    required this.controller,
    required this.width,
    required this.height,
    required this.circleDiameter,
  }) : super(key: key);

  void _seekToRelativePosition(Offset localPosition) {
    if (!controller.value.isInitialized ||
        controller.value.duration == Duration.zero)
      return;

    final newRatio = localPosition.dx / width;
    final clampedRatio = newRatio.clamp(0.0, 1.0);
    final duration = controller.value.duration;
    final newPosition = duration * clampedRatio;
    controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    final durationMs = controller.value.duration.inMilliseconds;
    final positionMs = controller.value.position.inMilliseconds;
    final progressRatio = durationMs > 0 ? positionMs / durationMs : 0.0;
    final double filledBarWidth = progressRatio * width;

    return GestureDetector(
      onTapDown: (details) {
        _seekToRelativePosition(details.localPosition);
      },
      onHorizontalDragUpdate: (details) {
        _seekToRelativePosition(details.localPosition);
      },
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Container(
              width: filledBarWidth,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Positioned(
              left: filledBarWidth - circleDiameter / 2,
              child: Container(
                width: circleDiameter,
                height: circleDiameter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
