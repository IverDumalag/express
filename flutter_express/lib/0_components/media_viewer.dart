import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaViewer extends StatelessWidget {
  final String filePath;
  final double scale;
  final VoidCallback? onFullScreenToggle;

  const MediaViewer({
    Key? key,
    required this.filePath,
    required this.scale,
    this.onFullScreenToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filePath.isEmpty) {
      return _NoMatchFound();
    } else if (filePath.toLowerCase().endsWith('.mp4') ||
        filePath.toLowerCase().endsWith('.mov')) {
      return _VideoPlayerWidget(
        filePath: filePath,
        onFullScreenToggle: onFullScreenToggle,
      );
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
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No Match Found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Unsupported media type',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
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
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: filePath.startsWith('http') || filePath.startsWith('https')
              ? Image.network(
                  filePath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Image.asset(
                  filePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Image not available',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  final VoidCallback? onFullScreenToggle;

  const _VideoPlayerWidget({
    Key? key,
    required this.filePath,
    this.onFullScreenToggle,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _isBuffering = false;

  final double displayWidth = 300;
  final double progressBarThickness = 6.0;
  final double circleDiameter = 16.0;

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
          // Video loading failed - the UI will handle this gracefully
          print("Error initializing video: $error");
        });

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _isBuffering = _controller.value.isBuffering;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(
        child: Container(
          width: displayWidth,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: displayWidth,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video display
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),

              // Buffering indicator
              if (_isBuffering)
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),

              // Fullscreen button
              if (widget.onFullScreenToggle != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onFullScreenToggle,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Controls section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Column(
              children: [
                _CustomProgressBar(
                  controller: _controller,
                  width: displayWidth - 32,
                  height: progressBarThickness,
                  circleDiameter: circleDiameter,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time indicator
                    Text(
                      _formatDuration(_controller.value.position),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),

                    // Control buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_left_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                _controller.seekTo(
                                  _controller.value.position -
                                      Duration(seconds: 1),
                                );
                              },
                            ),
                            Text(
                              '1s',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_right_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                _controller.seekTo(
                                  _controller.value.position +
                                      Duration(seconds: 1),
                                );
                              },
                            ),
                            Text(
                              '1s',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Right side controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Speed selector
                        PopupMenuButton<double>(
                          icon: Icon(Icons.speed_rounded, color: Colors.white),
                          itemBuilder: (context) => _speedOptions.map((speed) {
                            return PopupMenuItem<double>(
                              value: speed,
                              child: Text('${speed}x'),
                            );
                          }).toList(),
                          onSelected: (newSpeed) {
                            setState(() {
                              _playbackSpeed = newSpeed;
                              _controller.setPlaybackSpeed(_playbackSpeed);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "$minutes:${twoDigits(seconds)}";
    }
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
    final double bufferedEnd = controller.value.buffered.isNotEmpty
        ? controller.value.buffered.last.end.inMilliseconds / durationMs * width
        : 0.0;

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
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Buffered progress
            if (bufferedEnd > 0)
              Container(
                width: bufferedEnd,
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),

            // Played progress
            Container(
              width: filledBarWidth,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),

            // Thumb
            Positioned(
              left: filledBarWidth - circleDiameter / 2,
              child: Container(
                width: circleDiameter,
                height: circleDiameter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
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
