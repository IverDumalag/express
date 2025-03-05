import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaViewer extends StatelessWidget {
  final String filePath;
  final double scale;

  const MediaViewer({required this.filePath, required this.scale});

  @override
  Widget build(BuildContext context) {
    if (filePath.endsWith('.MOV')) {
      return _VideoAssetPlayer(filePath: filePath);
    } else if (filePath.endsWith('.png') || filePath.endsWith('.jpg')) {
      return _ImageAssetViewer(filePath: filePath);
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
            Text('No Match Found in our Dataset'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Feedback or Search'),
                      content: Text('This is a popup for feedback or search.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Feedback or Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAssetViewer extends StatelessWidget {
  final String filePath;

  const _ImageAssetViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRect(
        child: SizedBox(
          width: 300,
          height: 300,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: Image.asset(filePath),
          ),
        ),
      ),
    );
  }
}

class _VideoAssetPlayer extends StatefulWidget {
  final String filePath;

  const _VideoAssetPlayer({required this.filePath});

  @override
  __VideoAssetPlayerState createState() => __VideoAssetPlayerState();
}

class __VideoAssetPlayerState extends State<_VideoAssetPlayer> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 1.0, 1.5, 2.0];

  final double displayWidth = 300;
  final double progressBarThickness = 20.0;
  final double circleDiameter = 20.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.filePath)
      ..initialize().then((_) => setState(() {}));
    _controller.addListener(() {
      setState(() {});
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
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ClipRect(
            child: SizedBox(
              width: displayWidth,
              height: 300,
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),
        ),
        _CustomProgressBar(
          controller: _controller,
          width: displayWidth,
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
    required this.controller,
    required this.width,
    required this.height,
    required this.circleDiameter,
  });

  void _seekToRelativePosition(Offset localPosition) {
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
    final double redBarWidth = progressRatio * width;

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
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Container(
              width: redBarWidth,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            Positioned(
              left: redBarWidth - circleDiameter / 2,
              top: (height - circleDiameter) / 2,
              child: Container(
                width: circleDiameter,
                height: circleDiameter,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
