import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import '../0_components/popup_information.dart';

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
  bool _isFlickering = false;

  // Separate text storage for each model
  String _alphabetText = "";
  String _wordsText = "";

  // Crop variables
  bool _isCropped = false;
  Rect? _cropRect;
  Offset? _dragStart;
  bool _isDragging = false;
  String _dragMode = ''; // corner/edge/move/create

  final models = {"alphabet": "Alphabet", "words": "Words/Phrases"};

  @override
  void initState() {
    super.initState();
    _initCamera();

    // Show disclaimer popup when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerPopup();
    });
  }

  void _showDisclaimerPopup() async {
    await PopupInformation.show(
      context,
      title: "Dataset Information",
      message:
          "Note: The dataset is limited and may not recognize a sign language.",
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.setFlashMode(FlashMode.off);
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
              duration: const Duration(seconds: 2),
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

      // RESET CROP to avoid mirror mismatch after flipping
      setState(() {
        _cropRect = null;
        _isCropped = false;
      });

      if (mounted) setState(() {});

      // Restart timer
      _timer = Timer.periodic(const Duration(seconds: 4), (_) => _sendFrame());
    }
  }

  void _toggleCrop() {
    setState(() {
      _isCropped = !_isCropped;
    });

    if (_isCropped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final size = MediaQuery.of(context).size;
        final cameraWidth = size.width * 0.8;
        final cameraHeight = cameraWidth * (4 / 3);
        final cropSize = cameraWidth * 0.6;

        setState(() {
          _cropRect = Rect.fromCenter(
            center: Offset(cameraWidth / 2, cameraHeight / 2),
            width: cropSize,
            height: cropSize,
          );
        });
      });
    } else {
      setState(() => _cropRect = null);
    }
  }

  String _detectCropHandle(Offset position) {
    if (_cropRect == null) return '';

    const handleSize = 30.0; // Increased touch area for web/mobile
    const edgeThickness = 25.0; // Increased edge detection area

    // Corners
    if ((position.dx - _cropRect!.left).abs() < handleSize &&
        (position.dy - _cropRect!.top).abs() < handleSize) {
      return 'corner_tl';
    }
    if ((position.dx - _cropRect!.right).abs() < handleSize &&
        (position.dy - _cropRect!.top).abs() < handleSize) {
      return 'corner_tr';
    }
    if ((position.dx - _cropRect!.left).abs() < handleSize &&
        (position.dy - _cropRect!.bottom).abs() < handleSize) {
      return 'corner_bl';
    }
    if ((position.dx - _cropRect!.right).abs() < handleSize &&
        (position.dy - _cropRect!.bottom).abs() < handleSize) {
      return 'corner_br';
    }

    // Edges
    if ((position.dy - _cropRect!.top).abs() < edgeThickness &&
        position.dx > _cropRect!.left - edgeThickness &&
        position.dx < _cropRect!.right + edgeThickness) {
      return 'edge_top';
    }
    if ((position.dy - _cropRect!.bottom).abs() < edgeThickness &&
        position.dx > _cropRect!.left - edgeThickness &&
        position.dx < _cropRect!.right + edgeThickness) {
      return 'edge_bottom';
    }
    if ((position.dx - _cropRect!.left).abs() < edgeThickness &&
        position.dy > _cropRect!.top - edgeThickness &&
        position.dy < _cropRect!.bottom + edgeThickness) {
      return 'edge_left';
    }
    if ((position.dx - _cropRect!.right).abs() < edgeThickness &&
        position.dy > _cropRect!.top - edgeThickness &&
        position.dy < _cropRect!.bottom + edgeThickness) {
      return 'edge_right';
    }

    // Inside crop area
    if (_cropRect!.contains(position)) return 'move';

    return 'create'; // Dragging on empty space creates a new rect
  }

  void _onPanStart(DragStartDetails details) {
    if (!_isCropped) return;
    _dragStart = details.localPosition;
    _dragMode = _detectCropHandle(details.localPosition);
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isCropped || !_isDragging || _dragStart == null) return;

    final currentPos = details.localPosition;
    final delta = currentPos - _dragStart!;

    // Bounds must match the painted area
    final size = MediaQuery.of(context).size;
    final cameraWidth = size.width * 0.8;
    final cameraHeight = cameraWidth * (4 / 3);

    // Initialize rect on first create
    if (_dragMode == 'create' && _cropRect == null) {
      final left = _dragStart!.dx < currentPos.dx
          ? _dragStart!.dx
          : currentPos.dx;
      final top = _dragStart!.dy < currentPos.dy
          ? _dragStart!.dy
          : currentPos.dy;
      final right = _dragStart!.dx > currentPos.dx
          ? _dragStart!.dx
          : currentPos.dx;
      final bottom = _dragStart!.dy > currentPos.dy
          ? _dragStart!.dy
          : currentPos.dy;

      setState(() {
        _cropRect = Rect.fromLTRB(
          left.clamp(0.0, cameraWidth),
          top.clamp(0.0, cameraHeight),
          right.clamp(0.0, cameraWidth),
          bottom.clamp(0.0, cameraHeight),
        );
      });
      return;
    }

    if (_cropRect == null) return;

    setState(() {
      switch (_dragMode) {
        case 'corner_tl':
          _cropRect = Rect.fromLTRB(
            (_cropRect!.left + delta.dx).clamp(0.0, _cropRect!.right - 50),
            (_cropRect!.top + delta.dy).clamp(0.0, _cropRect!.bottom - 50),
            _cropRect!.right,
            _cropRect!.bottom,
          );
          break;
        case 'corner_tr':
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            (_cropRect!.top + delta.dy).clamp(0.0, _cropRect!.bottom - 50),
            (_cropRect!.right + delta.dx).clamp(
              _cropRect!.left + 50,
              cameraWidth,
            ),
            _cropRect!.bottom,
          );
          break;
        case 'corner_bl':
          _cropRect = Rect.fromLTRB(
            (_cropRect!.left + delta.dx).clamp(0.0, _cropRect!.right - 50),
            _cropRect!.top,
            _cropRect!.right,
            (_cropRect!.bottom + delta.dy).clamp(
              _cropRect!.top + 50,
              cameraHeight,
            ),
          );
          break;
        case 'corner_br':
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            _cropRect!.top,
            (_cropRect!.right + delta.dx).clamp(
              _cropRect!.left + 50,
              cameraWidth,
            ),
            (_cropRect!.bottom + delta.dy).clamp(
              _cropRect!.top + 50,
              cameraHeight,
            ),
          );
          break;
        case 'edge_top':
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            (_cropRect!.top + delta.dy).clamp(0.0, _cropRect!.bottom - 50),
            _cropRect!.right,
            _cropRect!.bottom,
          );
          break;
        case 'edge_bottom':
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            _cropRect!.top,
            _cropRect!.right,
            (_cropRect!.bottom + delta.dy).clamp(
              _cropRect!.top + 50,
              cameraHeight,
            ),
          );
          break;
        case 'edge_left':
          _cropRect = Rect.fromLTRB(
            (_cropRect!.left + delta.dx).clamp(0.0, _cropRect!.right - 50),
            _cropRect!.top,
            _cropRect!.right,
            _cropRect!.bottom,
          );
          break;
        case 'edge_right':
          _cropRect = Rect.fromLTRB(
            _cropRect!.left,
            _cropRect!.top,
            (_cropRect!.right + delta.dx).clamp(
              _cropRect!.left + 50,
              cameraWidth,
            ),
            _cropRect!.bottom,
          );
          break;
        case 'move':
          final width = _cropRect!.width;
          final height = _cropRect!.height;
          final newLeft = (_cropRect!.left + delta.dx).clamp(
            0.0,
            cameraWidth - width,
          );
          final newTop = (_cropRect!.top + delta.dy).clamp(
            0.0,
            cameraHeight - height,
          );
          _cropRect = Rect.fromLTWH(newLeft, newTop, width, height);
          break;
        case 'create':
          final left = _dragStart!.dx < currentPos.dx
              ? _dragStart!.dx
              : currentPos.dx;
          final top = _dragStart!.dy < currentPos.dy
              ? _dragStart!.dy
              : currentPos.dy;
          final right = _dragStart!.dx > currentPos.dx
              ? _dragStart!.dx
              : currentPos.dx;
          final bottom = _dragStart!.dy > currentPos.dy
              ? _dragStart!.dy
              : currentPos.dy;

          _cropRect = Rect.fromLTRB(
            left.clamp(0.0, cameraWidth),
            top.clamp(0.0, cameraHeight),
            right.clamp(0.0, cameraWidth),
            bottom.clamp(0.0, cameraHeight),
          );
          break;
      }
    });

    _dragStart = currentPos; // smooth continuous drag
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _dragStart = null;
      _dragMode = '';
    });
  }

  // Apply crop to captured image file if crop mode is active
  Future<File> _maybeCropFile(File original) async {
    if (!_isCropped || _cropRect == null) return original;

    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return original;

    // Overlay preview dimensions
    final screenSize = MediaQuery.of(context).size;
    final previewW = screenSize.width * 0.8;
    final previewH = previewW * (4 / 3);

    // Real image size
    final imgW = decoded.width.toDouble();
    final imgH = decoded.height.toDouble();

    // Scale from preview space -> pixels
    final scaleX = imgW / previewW;
    final scaleY = imgH / previewH;

    // Mirror handling for front camera
    final isFront =
        _cameras != null &&
        _cameras!.isNotEmpty &&
        _cameras![_currentCameraIndex].lensDirection ==
            CameraLensDirection.front;

    final leftPreview = isFront
        ? (previewW - _cropRect!.right)
        : _cropRect!.left;
    final topPreview = _cropRect!.top;

    int leftPx = (leftPreview * scaleX).round();
    int topPx = (topPreview * scaleY).round();
    int widthPx = (_cropRect!.width * scaleX).round();
    int heightPx = (_cropRect!.height * scaleY).round();

    leftPx = leftPx.clamp(0, imgW.toInt() - 1);
    topPx = topPx.clamp(0, imgH.toInt() - 1);
    widthPx = widthPx.clamp(1, imgW.toInt() - leftPx);
    heightPx = heightPx.clamp(1, imgH.toInt() - topPx);

    final cropped = img.copyCrop(
      decoded,
      x: leftPx,
      y: topPx,
      width: widthPx,
      height: heightPx,
    );

    final croppedBytes = img.encodeJpg(cropped, quality: 95);
    await original.writeAsBytes(croppedBytes, flush: true);
    return original;
  }

  Future<void> _sendFrame() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    setState(() => _isFlickering = true);
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isFlickering = false);
    });

    try {
      final picture = await _cameraController!.takePicture();
      File file = File(picture.path);

      file = await _maybeCropFile(file);

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
            final predictionText =
                decoded is Map && decoded.containsKey("label")
                ? decoded["label"].toString().trim()
                : responseData.toString().trim();

            if (predictionText.isNotEmpty && predictionText != "Waiting...") {
              if (predictionText.toLowerCase() == "nosign") {
                String message = _selectedModel == "alphabet"
                    ? "No hand detected"
                    : "No silhouette detected";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message, style: GoogleFonts.robotoMono()),
                    backgroundColor: Colors.orange,
                    duration: const Duration(milliseconds: 800),
                  ),
                );
                return;
              }

              setState(() {
                _prediction = predictionText;
                if (_selectedModel == "alphabet") {
                  _alphabetText = _alphabetText.isEmpty
                      ? predictionText
                      : '$_alphabetText $predictionText';
                } else {
                  _wordsText = _wordsText.isEmpty
                      ? predictionText
                      : '$_wordsText $predictionText';
                }
                _textController.text = _selectedModel == "alphabet"
                    ? _alphabetText
                    : _wordsText;
              });
            }
          } catch (e) {
            final cleaned = responseData.replaceAll('"', '').trim();
            if (cleaned.isNotEmpty &&
                cleaned != "Waiting..." &&
                cleaned.toLowerCase() != "nosign") {
              setState(() {
                _prediction = cleaned;
                if (_selectedModel == "alphabet") {
                  _alphabetText = _alphabetText.isEmpty
                      ? cleaned
                      : '$_alphabetText $cleaned';
                } else {
                  _wordsText = _wordsText.isEmpty
                      ? cleaned
                      : '$_wordsText $cleaned';
                }
                _textController.text = _selectedModel == "alphabet"
                    ? _alphabetText
                    : _wordsText;
              });
            } else if (cleaned.toLowerCase() == "nosign") {
              String message = _selectedModel == "alphabet"
                  ? "No hand detected"
                  : "No silhouette detected";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message, style: GoogleFonts.robotoMono()),
                  backgroundColor: Colors.orange,
                  duration: const Duration(milliseconds: 800),
                ),
              );
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
      if (_selectedModel == "alphabet") {
        _alphabetText = "";
      } else {
        _wordsText = "";
      }
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    final cameraWidth = screenSize.width * 0.8;
    // Use fixed 4:3 aspect ratio for the container
    // Camera will fill this space and excess will be cropped
    final cameraHeight = cameraWidth * (4 / 3);

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
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
            tooltip: _isFlashOn ? 'Turn Off Flash' : 'Turn On Flash',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
            onPressed: _flipCamera,
            tooltip: 'Flip Camera',
          ),
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
                          // 1) Camera preview (bottom) - uses BoxFit.cover to fill and crop excess
                          Positioned.fill(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!
                                    .value
                                    .previewSize!
                                    .height,
                                height:
                                    _cameraController!.value.previewSize!.width,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          ),

                          // 2) Scan overlay (visual only) — DO NOT capture gestures
                          Positioned.fill(
                            child: IgnorePointer(
                              ignoring: true,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedOpacity(
                                  opacity: _isFlickering ? 0.8 : 0.5,
                                  duration: const Duration(milliseconds: 100),
                                  child: Image.asset(
                                    _selectedModel == "alphabet"
                                        ? 'assets/images/HandScan.png'
                                        : 'assets/images/PersonScan.png',
                                    fit: BoxFit.cover,
                                    width: cameraWidth,
                                    height: cameraHeight,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3) Camera info (also non-interactive)
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: IgnorePointer(
                              ignoring: true,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF334E7B,
                                  ).withOpacity(0.9),
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
                          ),

                          // 4) Crop instructions (non-interactive)
                          if (_isCropped)
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: IgnorePointer(
                                ignoring: true,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF334E7B,
                                    ).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Drag corners to resize • Drag edges to adjust • Drag inside to move',
                                    style: GoogleFonts.robotoMono(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                          // 5) CROP OVERLAY (top-most, captures gestures)
                          if (_isCropped)
                            Positioned.fill(
                              child: MouseRegion(
                                cursor: _isDragging
                                    ? SystemMouseCursors.grabbing
                                    : SystemMouseCursors.grab,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanStart: _onPanStart,
                                  onPanUpdate: _onPanUpdate,
                                  onPanEnd: _onPanEnd,
                                  child: CustomPaint(
                                    painter: CropOverlayPainter(
                                      cropRect: _cropRect,
                                      screenSize: Size(
                                        cameraWidth,
                                        cameraHeight,
                                      ),
                                    ),
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
                minHeight: screenSize.height - cameraHeight - 150,
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
                                _textController.text =
                                    _selectedModel == "alphabet"
                                    ? _alphabetText
                                    : _wordsText;
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
                          const Icon(
                            Icons.crop,
                            color: Color(0xFF334E7B),
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
                        height: 200,
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
                          readOnly: true,
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

                  const SizedBox(height: 20),
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
      ..color = Colors.black38
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF334E7B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final handlePaint = Paint()
      ..color = const Color(0xFF334E7B)
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dim outside area
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRect(cropRect!);
    final finalPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );
    canvas.drawPath(finalPath, paint);

    // Border
    canvas.drawRect(cropRect!, borderPaint);

    // Corner handles
    const handleSize = 16.0;
    final corners = [
      Offset(cropRect!.left, cropRect!.top),
      Offset(cropRect!.right, cropRect!.top),
      Offset(cropRect!.left, cropRect!.bottom),
      Offset(cropRect!.right, cropRect!.bottom),
    ];
    for (final corner in corners) {
      final handleRect = Rect.fromCenter(
        center: corner,
        width: handleSize,
        height: handleSize,
      );
      canvas.drawRect(handleRect, handleBorderPaint);
      canvas.drawRect(handleRect, handlePaint);
    }

    // Edge handles
    const edgeHandleSize = 12.0;
    final edgeHandlePaint = Paint()
      ..color = const Color(0xFF334E7B)
      ..style = PaintingStyle.fill;

    final edges = [
      Offset(cropRect!.center.dx, cropRect!.top),
      Offset(cropRect!.center.dx, cropRect!.bottom),
      Offset(cropRect!.left, cropRect!.center.dy),
      Offset(cropRect!.right, cropRect!.center.dy),
    ];
    for (final edge in edges) {
      canvas.drawCircle(edge, edgeHandleSize / 2 + 1, handleBorderPaint);
      canvas.drawCircle(edge, edgeHandleSize / 2, edgeHandlePaint);
    }

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF334E7B).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final thirdWidth = cropRect!.width / 3;
    canvas.drawLine(
      Offset(cropRect!.left + thirdWidth, cropRect!.top),
      Offset(cropRect!.left + thirdWidth, cropRect!.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect!.left + thirdWidth * 2, cropRect!.top),
      Offset(cropRect!.left + thirdWidth * 2, cropRect!.bottom),
      gridPaint,
    );

    final thirdHeight = cropRect!.height / 3;
    canvas.drawLine(
      Offset(cropRect!.left, cropRect!.top + thirdHeight),
      Offset(cropRect!.right, cropRect!.top + thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect!.left, cropRect!.top + thirdHeight * 2),
      Offset(cropRect!.right, cropRect!.top + thirdHeight * 2),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
