import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class SignToTextPage extends StatefulWidget {
  const SignToTextPage({super.key});

  @override
  State<SignToTextPage> createState() => _SignToTextPageState();
}

class _SignToTextPageState extends State<SignToTextPage> {
  CameraController? _cameraController;
  String _prediction = "";
  String _selectedModel = "alphabet";
  Timer? _timer;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  final TextEditingController _textController = TextEditingController();
  bool _isFlashOn = false;

  // Crop variables
  bool _isCropped = false;
  Rect? _cropRect;
  Offset? _dragStart;
  Offset? _dragEnd;
  bool _isDragging = false;

  final models = {"alphabet": "Alphabet", "words": "Words/Phrases"};

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.setFlashMode(
      FlashMode.off,
    ); // Turn off flash before disposing
    _cameraController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() {});

      // Start sending every 4 seconds
      _timer = Timer.periodic(const Duration(seconds: 4), (_) => _sendFrame());
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
        await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      } catch (e) {
        // Flash not supported, revert state and show user-friendly message
        setState(() {
          _isFlashOn = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Flash is not available on this camera',
                style: GoogleFonts.robotoMono(),
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras != null && _cameras!.length > 1) {
      _timer?.cancel();

      // Turn off flash before switching cameras
      if (_cameraController != null && _isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() {
          _isFlashOn = false;
        });
      }

      await _cameraController?.dispose();

      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;

      _cameraController = CameraController(
        _cameras![_currentCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});

      // Restart timer
      _timer = Timer.periodic(const Duration(seconds: 4), (_) => _sendFrame());
    }
  }

  void _toggleCrop() {
    setState(() {
      _isCropped = !_isCropped;
      if (!_isCropped) {
        _cropRect = null;
      } else {
        // Set default crop area (center square) - adjusted for smaller camera
        final size = MediaQuery.of(context).size;
        final cameraWidth = size.width * 0.8;
        final cameraHeight = cameraWidth * (4 / 3);
        final centerX = cameraWidth / 2;
        final centerY = cameraHeight / 2;
        final cropSize = cameraWidth * 0.6;

        _cropRect = Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: cropSize,
          height: cropSize,
        );
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isCropped) {
      setState(() {
        _dragStart = details.localPosition;
        _isDragging = true;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCropped && _isDragging && _dragStart != null) {
      setState(() {
        _dragEnd = details.localPosition;

        final left = _dragStart!.dx < _dragEnd!.dx
            ? _dragStart!.dx
            : _dragEnd!.dx;
        final top = _dragStart!.dy < _dragEnd!.dy
            ? _dragStart!.dy
            : _dragEnd!.dy;
        final right = _dragStart!.dx > _dragEnd!.dx
            ? _dragStart!.dx
            : _dragEnd!.dx;
        final bottom = _dragStart!.dy > _dragEnd!.dy
            ? _dragStart!.dy
            : _dragEnd!.dy;

        _cropRect = Rect.fromLTRB(left, top, right, bottom);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragEnd = null;
    });
  }

  Future<void> _sendFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final picture = await _cameraController!.takePicture();
      final file = File(picture.path);

      final uri = Uri.parse(
        "https://express-nodejs-nc12.onrender.com/predict/$_selectedModel",
      );

      final request = http.MultipartRequest("POST", uri)
        ..files.add(await http.MultipartFile.fromPath("image", file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        if (mounted && responseData.isNotEmpty) {
          try {
            final decoded = jsonDecode(responseData);

            // Get only the "label" value
            final predictionText =
                decoded is Map && decoded.containsKey("label")
                ? decoded["label"].toString().trim()
                : responseData.toString().trim();

            if (predictionText.isNotEmpty && predictionText != "Waiting...") {
              setState(() {
                _prediction = predictionText;
                if (_textController.text.isEmpty) {
                  _textController.text = predictionText;
                } else {
                  _textController.text += ' $predictionText';
                }
              });
            }
          } catch (e) {
            // fallback if it's not JSON
            final cleaned = responseData.replaceAll('"', '').trim();
            if (cleaned.isNotEmpty && cleaned != "Waiting...") {
              setState(() {
                _prediction = cleaned;
                if (_textController.text.isEmpty) {
                  _textController.text = cleaned;
                } else {
                  _textController.text += ' $cleaned';
                }
              });
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _prediction = "Unable to connect to translation service";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = "Translation temporarily unavailable";

        // Check for specific error types
        if (e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          errorMessage = "Check your internet connection";
        } else if (e.toString().contains('camera') ||
            e.toString().contains('permission')) {
          errorMessage = "Camera access needed for translation";
        }

        setState(() {
          _prediction = errorMessage;
        });
      }
    }
  }

  void _clearText() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final cameraWidth = screenSize.width * 0.8; // 20% smaller
    final cameraHeight = cameraWidth * (4 / 3); // Same ratio

    return Scaffold(
      backgroundColor: const Color(0xFF334E7B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF334E7B),
        title: Text(
          "Sign → Text",
          style: GoogleFonts.robotoMono(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          // Help/Info button
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: Color(0xFF334E7B),
                        width: 2,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    title: Text(
                      'How to Use Sign → Text',
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFF334E7B),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🤟 Position your hand in front of the camera',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '📱 Switch between Alphabet and Words/Phrases modes',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '⚡ Use flash for better lighting',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🔄 Flip between front/back camera',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '✂️ Use crop to focus on specific area',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '📝 Translations appear automatically in the text box',
                            style: GoogleFonts.robotoMono(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Got it!',
                          style: GoogleFonts.robotoMono(
                            color: const Color(0xFF334E7B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Help & Instructions',
          ),
          // Flash toggle button
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
            tooltip: _isFlashOn ? 'Turn Off Flash' : 'Turn On Flash',
          ),
          // Camera flip button
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: _flipCamera,
            tooltip: 'Flip Camera',
          ),
          // Crop toggle button
          IconButton(
            icon: Icon(
              _isCropped ? Icons.crop_free : Icons.crop,
              color: Colors.white,
            ),
            onPressed: _toggleCrop,
            tooltip: _isCropped ? 'Remove Crop' : 'Crop Camera',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Camera preview with crop functionality
            Container(
              width: cameraWidth,
              height: cameraHeight,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? Stack(
                        children: [
                          // Camera preview
                          Positioned.fill(
                            child: AspectRatio(
                              aspectRatio: _cameraController!.value.aspectRatio,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),

                          // Crop overlay
                          if (_isCropped)
                            Positioned.fill(
                              child: GestureDetector(
                                onPanStart: _onPanStart,
                                onPanUpdate: _onPanUpdate,
                                onPanEnd: _onPanEnd,
                                child: CustomPaint(
                                  painter: CropOverlayPainter(
                                    cropRect: _cropRect,
                                    screenSize: Size(cameraWidth, cameraHeight),
                                  ),
                                ),
                              ),
                            ),

                          // Crop instructions
                          if (_isCropped)
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF334E7B,
                                  ).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Drag to select capture area',
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          // Camera info
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334E7B).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _cameras != null &&
                                        _cameras!.length > _currentCameraIndex
                                    ? (_cameras![_currentCameraIndex]
                                                  .lensDirection ==
                                              CameraLensDirection.front
                                          ? 'Front'
                                          : 'Back')
                                    : 'Camera',
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: Colors.grey[900],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Initializing camera...',
                                style: GoogleFonts.robotoMono(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            // Controls section
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height -
                    cameraHeight -
                    150, // Ensure minimum height
              ),
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Model selection tabs
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: models.entries.map((entry) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedModel = entry.key;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedModel == entry.key
                                    ? const Color(0xFF334E7B)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                entry.value,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.robotoMono(
                                  color: _selectedModel == entry.key
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Crop status
                  if (_isCropped)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334E7B).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF334E7B).withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.crop,
                            color: const Color(0xFF334E7B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Crop mode active - Only selected area will be analyzed',
                              style: GoogleFonts.robotoMono(
                                color: const Color(0xFF334E7B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_isCropped) const SizedBox(height: 20),

                  // Translation text field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Translation:',
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF334E7B),
                            ),
                          ),
                          if (_textController.text.isNotEmpty)
                            TextButton.icon(
                              onPressed: _clearText,
                              icon: const Icon(
                                Icons.clear,
                                size: 16,
                                color: Color(0xFF334E7B),
                              ),
                              label: Text(
                                'Clear',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12,
                                  color: const Color(0xFF334E7B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200, // Fixed height for text field
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF334E7B).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF334E7B).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          style: GoogleFonts.robotoMono(
                            fontSize: isSmallScreen ? 16 : 18,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Sign language translations will appear here...',
                            hintStyle: GoogleFonts.robotoMono(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect? cropRect;
  final Size screenSize;

  CropOverlayPainter({required this.cropRect, required this.screenSize});

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect == null) return;

    final paint = Paint()
      ..color = Colors
          .black26 // More transparent overlay
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF334E7B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw semi-transparent overlay outside cropRect
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(cropRect!);
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );

    canvas.drawPath(finalPath, paint);

    // Draw crop border
    canvas.drawRect(cropRect!, borderPaint);

    // Draw corner handles (smaller and more subtle)
    final handleSize = 12.0;
    final handlePaint = Paint()
      ..color = const Color(0xFF334E7B)
      ..style = PaintingStyle.fill;

    // Top-left handle
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect!.left - handleSize / 2,
        cropRect!.top - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Top-right handle
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect!.right - handleSize / 2,
        cropRect!.top - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Bottom-left handle
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect!.left - handleSize / 2,
        cropRect!.bottom - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Bottom-right handle
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect!.right - handleSize / 2,
        cropRect!.bottom - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
