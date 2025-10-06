import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_express/0_components/media_viewer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../1_home/home_cards.dart';

class AudioCardDetailScreen extends StatelessWidget {
  final Map<String, dynamic> phrase;
  final double scale;

  const AudioCardDetailScreen({
    Key? key,
    required this.phrase,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayText = phrase['words'] ?? '';
    final signLanguagePath = phrase['sign_language'] ?? '';
    final createdAt = phrase['created_at'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('', style: GoogleFonts.robotoMono()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [],
      ),
      body: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: GoogleFonts.robotoMono(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334E7B),
                    ),
                  ),
                ),
                SizedBox(width: 8 * scale),
                InteractiveSpeakerIcon(
                  scale: scale,
                  text: displayText,
                  color: Color(0xFF334E7B),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            Text(
              'Created: $createdAt',
              style: GoogleFonts.robotoMono(
                fontSize: 16 * scale,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24 * scale),
            if (signLanguagePath.isNotEmpty)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12 * scale),
                    child: MediaViewer(
                      filePath: signLanguagePath,
                      scale: scale,
                      onFullScreenToggle: () => _enterFullScreen(
                        context,
                        signLanguagePath,
                        displayText,
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32 * scale),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48 * scale,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      "No Match Found",
                      style: GoogleFonts.robotoMono(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      "No sign language equivalent available for this phrase",
                      style: GoogleFonts.robotoMono(
                        fontSize: 12 * scale,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _enterFullScreen(BuildContext context, String filePath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FullScreenMediaViewer(filePath: filePath, title: title),
      ),
    );
  }
}

class FullScreenMediaViewer extends StatefulWidget {
  final String filePath;
  final String title;

  const FullScreenMediaViewer({
    Key? key,
    required this.filePath,
    required this.title,
  }) : super(key: key);

  @override
  _FullScreenMediaViewerState createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  bool _showControls = true;
  bool _isFullScreen = true; // Start in full-screen mode

  @override
  void initState() {
    super.initState();
    // Automatically enter landscape full-screen mode when opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enterFullScreenLandscape();
    });
  }

  void _enterFullScreenLandscape() {
    // Automatically enter landscape full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      _enterFullScreenLandscape();
    } else {
      // Restore normal mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _exitFullScreen() {
    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCurrentlyLandscape = screenSize.width > screenSize.height;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _exitFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullScreen
            ? null
            : AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  widget.title,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _exitFullScreen,
                ),
              ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double mediaWidth;
              double mediaHeight;

              if (_isFullScreen || isCurrentlyLandscape) {
                // In full screen or landscape mode, use entire screen
                mediaWidth = constraints.maxWidth;
                mediaHeight = constraints.maxHeight;
              } else {
                // Portrait mode with some padding
                mediaWidth = constraints.maxWidth * 0.95;
                mediaHeight = constraints.maxHeight * 0.8;
              }

              return Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showControls = !_showControls;
                    });
                  },
                  child: Container(
                    width: mediaWidth,
                    height: mediaHeight,
                    child: _FullScreenMediaWidget(
                      filePath: widget.filePath,
                      width: mediaWidth,
                      height: mediaHeight,
                      showControls: _showControls,
                      isFullScreen: _isFullScreen,
                      onFullScreenToggle: _toggleFullScreen,
                      onExit: _exitFullScreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Restore system UI when disposing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}

class _FullScreenMediaWidget extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;
  final bool showControls;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;
  final VoidCallback onExit;

  const _FullScreenMediaWidget({
    Key? key,
    required this.filePath,
    required this.width,
    required this.height,
    required this.showControls,
    required this.isFullScreen,
    required this.onFullScreenToggle,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (filePath.isEmpty) {
      return _FullScreenNoMatchFound();
    } else if (filePath.toLowerCase().endsWith('.mp4') ||
        filePath.toLowerCase().endsWith('.mov')) {
      return _FullScreenVideoPlayer(
        filePath: filePath,
        width: width,
        height: height,
        showControls: showControls,
        onExit: onExit,
      );
    } else if (filePath.toLowerCase().endsWith('.png') ||
        filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg')) {
      return _FullScreenImageViewer(
        filePath: filePath,
        width: width,
        height: height,
        showControls: showControls,
        isFullScreen: isFullScreen,
        onFullScreenToggle: onFullScreenToggle,
        onExit: onExit,
      );
    } else {
      return _FullScreenNoMatchFound();
    }
  }
}

class _FullScreenNoMatchFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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

class _FullScreenImageViewer extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;
  final bool showControls;
  final bool isFullScreen;
  final VoidCallback onFullScreenToggle;
  final VoidCallback onExit;

  const _FullScreenImageViewer({
    Key? key,
    required this.filePath,
    required this.width,
    required this.height,
    required this.showControls,
    required this.isFullScreen,
    required this.onFullScreenToggle,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: isFullScreen
            ? BorderRadius.zero
            : BorderRadius.circular(12),
        boxShadow: isFullScreen
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: isFullScreen
                ? BorderRadius.zero
                : BorderRadius.circular(12),
            child: filePath.startsWith('http') || filePath.startsWith('https')
                ? Image.network(
                    filePath,
                    fit: BoxFit.contain,
                    width: width,
                    height: height,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[800],
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
                                color: Colors.grey[400],
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
                    fit: BoxFit.contain,
                    width: width,
                    height: height,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[800],
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
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Full screen controls overlay
          if (showControls && !isFullScreen)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onFullScreenToggle,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.fullscreen, color: Colors.white, size: 24),
                ),
              ),
            ),
          if (showControls && isFullScreen)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: onExit,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String filePath;
  final double width;
  final double height;
  final bool showControls;
  final VoidCallback onExit;

  const _FullScreenVideoPlayer({
    Key? key,
    required this.filePath,
    required this.width,
    required this.height,
    required this.showControls,
    required this.onExit,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  double _playbackSpeed = 1.0;
  final List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  bool _isBuffering = false;

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

    _controller.addListener(_videoListener);
    _controller
        .initialize()
        .then((_) {
          setState(() {});
          _controller.play();
        })
        .catchError((error) {
          print('Video initialization error: $error');
        });
  }

  void _videoListener() {
    if (mounted) {
      final bool isBuffering = _controller.value.isBuffering;
      if (isBuffering != _isBuffering) {
        setState(() {
          _isBuffering = isBuffering;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
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
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player - scale to fit the full screen
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Buffering indicator
          if (_isBuffering)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

          // Play/Pause button in center
          if (!_controller.value.isPlaying && !_isBuffering)
            Positioned(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 48),
                ),
              ),
            ),

          // Top controls
          if (widget.showControls)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Speed control
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<double>(
                      value: _playbackSpeed,
                      style: TextStyle(color: Colors.white),
                      dropdownColor: Colors.black87,
                      underline: Container(),
                      items: _speedOptions.map((speed) {
                        return DropdownMenuItem<double>(
                          value: speed,
                          child: Text('${speed}x'),
                        );
                      }).toList(),
                      onChanged: (newSpeed) {
                        if (newSpeed != null) {
                          setState(() {
                            _playbackSpeed = newSpeed;
                            _controller.setPlaybackSpeed(_playbackSpeed);
                          });
                        }
                      },
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: widget.onExit,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom controls
          if (widget.showControls)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Back 10s
                    GestureDetector(
                      onTap: () {
                        final currentPosition = _controller.value.position;
                        final newPosition =
                            currentPosition - Duration(seconds: 10);
                        _controller.seekTo(
                          newPosition >= Duration.zero
                              ? newPosition
                              : Duration.zero,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Play/Pause
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Forward 10s
                    GestureDetector(
                      onTap: () {
                        final currentPosition = _controller.value.position;
                        final newPosition =
                            currentPosition + Duration(seconds: 10);
                        final duration = _controller.value.duration;
                        _controller.seekTo(
                          newPosition <= duration ? newPosition : duration,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Progress bar
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, VideoPlayerValue value, child) {
                          return LinearProgressIndicator(
                            value:
                                value.position.inMilliseconds /
                                value.duration.inMilliseconds.clamp(
                                  1,
                                  double.infinity,
                                ),
                            backgroundColor: Colors.grey[600],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    // Time display
                    ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return Text(
                          '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
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
