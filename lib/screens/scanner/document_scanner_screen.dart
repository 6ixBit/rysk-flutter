import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class DocumentScannerScreen extends StatefulWidget {
  const DocumentScannerScreen({super.key});

  @override
  State<DocumentScannerScreen> createState() => _DocumentScannerScreenState();
}

class _DocumentScannerScreenState extends State<DocumentScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _isFlashOn = false;
  List<File> _capturedImages = [];
  final _uuid = const Uuid();

  // Camera overlay dimensions
  final double _overlayHeight = 0.7;
  final double _overlayWidth = 0.9;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final controller = CameraController(
      firstCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _controller = controller;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      setState(() => _isCapturing = true);

      // Turn off flash for capture if it was on as torch
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.auto);
      }

      final XFile image = await controller.takePicture();

      // Restore torch if it was on
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.torch);
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String id = _uuid.v4();

      // Create a directory for our app's images if it doesn't exist
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String dirPath = path.join(appDir.path, 'scanned_documents');
      await Directory(dirPath).create(recursive: true);

      // Compress and save the image
      final String targetPath = path.join(dirPath, '${timestamp}_$id.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 85,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        setState(() {
          _capturedImages.add(File(result.path));
          _isCapturing = false;
        });
      } else {
        setState(() => _isCapturing = false);
      }
    } catch (e) {
      setState(() => _isCapturing = false);
      debugPrint('Error capturing image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      final file = _capturedImages[index];
      _capturedImages.removeAt(index);
      file.delete();
    });
  }

  Future<void> _finishScanning() async {
    if (_capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture at least one page')),
      );
      return;
    }

    // Turn off flash before exiting
    if (_isFlashOn && _controller != null) {
      await _controller!.setFlashMode(FlashMode.off);
    }

    Navigator.pop(context, _capturedImages);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(child: CameraPreview(_controller!)),

          // Document Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: DocumentOverlayPainter(
                overlayHeight: _overlayHeight,
                overlayWidth: _overlayWidth,
              ),
            ),
          ),

          // Instruction Text
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Align document within the frame',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () async {
                        if (_isFlashOn && _controller != null) {
                          await _controller!.setFlashMode(FlashMode.off);
                        }
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Scan Document',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar with Captured Images
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_capturedImages.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _capturedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _capturedImages[index],
                                      height: 100,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (_capturedImages.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _finishScanning,
                              icon: const Icon(Icons.check),
                              label: Text('Done (${_capturedImages.length})'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            )
                          else
                            const SizedBox(width: 120),

                          // Capture Button
                          GestureDetector(
                            onTap: _captureImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: _isCapturing
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                            ),
                          ),

                          if (_capturedImages.isNotEmpty)
                            const SizedBox(width: 120)
                          else
                            const SizedBox(width: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentOverlayPainter extends CustomPainter {
  final double overlayHeight;
  final double overlayWidth;

  DocumentOverlayPainter({
    required this.overlayHeight,
    required this.overlayWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final overlayRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * overlayWidth,
      height: size.height * overlayHeight,
    );

    // Draw the semi-transparent overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRect(overlayRect),
      ),
      paint,
    );

    // Draw the document frame
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(overlayRect, const Radius.circular(8)),
      framePaint,
    );

    // Draw corner guides
    const cornerLength = 25.0;
    const cornerThickness = 4.0;

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round;

    final corners = [
      // Top-left
      [
        Offset(overlayRect.left, overlayRect.top + cornerLength),
        Offset(overlayRect.left, overlayRect.top),
        Offset(overlayRect.left + cornerLength, overlayRect.top),
      ],
      // Top-right
      [
        Offset(overlayRect.right - cornerLength, overlayRect.top),
        Offset(overlayRect.right, overlayRect.top),
        Offset(overlayRect.right, overlayRect.top + cornerLength),
      ],
      // Bottom-right
      [
        Offset(overlayRect.right, overlayRect.bottom - cornerLength),
        Offset(overlayRect.right, overlayRect.bottom),
        Offset(overlayRect.right - cornerLength, overlayRect.bottom),
      ],
      // Bottom-left
      [
        Offset(overlayRect.left + cornerLength, overlayRect.bottom),
        Offset(overlayRect.left, overlayRect.bottom),
        Offset(overlayRect.left, overlayRect.bottom - cornerLength),
      ],
    ];

    for (final corner in corners) {
      canvas.drawLine(corner[0], corner[1], cornerPaint);
      canvas.drawLine(corner[1], corner[2], cornerPaint);
    }
  }

  @override
  bool shouldRepaint(DocumentOverlayPainter oldDelegate) =>
      overlayHeight != oldDelegate.overlayHeight ||
      overlayWidth != oldDelegate.overlayWidth;
}
