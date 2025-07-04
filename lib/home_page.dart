import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart'; // agar bisa akses interpreter
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceExpressionDetectorPage extends StatefulWidget {
  const FaceExpressionDetectorPage({super.key});

  @override
  State<FaceExpressionDetectorPage> createState() => _FaceExpressionDetectorPageState();
}

class _FaceExpressionDetectorPageState extends State<FaceExpressionDetectorPage>
    with SingleTickerProviderStateMixin {
  File? _imageFile;
  String _expressionResult = '';
  String _expressionEmoji = '';
  bool _isAnalyzing = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _expressionResult = '';
        _expressionEmoji = '';
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _expressionResult = '';
        _expressionEmoji = '';
      });
    }
  }

  Future<void> _detectExpression() async {
    setState(() {
      _isAnalyzing = true;
    });

    if (_imageFile == null) return;

    // 1. Baca dan resize gambar
    final bytes = await _imageFile!.readAsBytes();
    img.Image? oriImage = img.decodeImage(bytes);

    // Face detection
    final inputImage = InputImage.fromFile(_imageFile!);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: false,
        enableLandmarks: false,
      ),
    );
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first.boundingBox;
      // Crop ROI wajah dari oriImage (pakai package image)
      img.Image faceCrop = img.copyCrop(
        oriImage!,
        x: face.left.toInt(),
        y: face.top.toInt(),
        width: face.width.toInt(),
        height: face.height.toInt(),
      );
      img.Image resized = img.copyResize(faceCrop, width: 48, height: 48);

      // 2. Konversi ke grayscale dan normalisasi [0,1]
      var input = List.generate(1, (_) => List.generate(48, (y) => List.generate(48, (x) => [img.getLuminance(resized.getPixel(x, y)) / 255.0])));

      // 3. Siapkan output (misal 7 kelas)
      var output = [List.filled(7, 0.0)];

      // 4. Inference
      interpreter.run(input, output);

      // Print output model untuk debugging
      print('Output model: $output');

      // 5. Ambil hasil prediksi
      int maxIdx = 0;
      double maxVal = output[0][0];
      for (int i = 1; i < 7; i++) {
        if (output[0][i] > maxVal) {
          maxVal = output[0][i];
          maxIdx = i;
        }
      }

      // 6. Label dan emoji (ubah sesuai model kamu)
      List<String> labels = [
        'Angry', 'Disgust', 'Fear', 'Happy', 'Neutral', 'Sad', 'Surprise'
      ];
      List<String> emojis = [
        '😠', '🤢', '😲', '😄', '😐', '😢', '😱'
      ];

      setState(() {
        _expressionResult = labels[maxIdx];
        _expressionEmoji = emojis[maxIdx];
        _isAnalyzing = false;
      });

      _animationController.forward(from: 0);
    } else {
      setState(() {
        _expressionResult = 'Tidak ada wajah terdeteksi';
        _expressionEmoji = '';
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // solid white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildGreetingCard(),
                      const SizedBox(height: 25),
                      _buildImageSection(),
                      const SizedBox(height: 25),
                      _buildActionButtons(),
                      const SizedBox(height: 25),
                      if (_expressionResult.isNotEmpty) _buildResultSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Deteksi Ekspresi',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hapus logo di sini:
          // Container(
          //   width: 48,
          //   height: 48,
          //   decoration: const BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: Color(0xFFFFB800),
          //   ),
          //   child: Center(
          //     child: Image.asset(
          //       'assets/images/emoji_bg.png',
          //       width: 36,
          //       height: 36,
          //       fit: BoxFit.contain,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _expressionResult.isEmpty
                      ? 'Yuk lihat ekspresimu hari ini!'
                      : 'Ekspresi kamu hari ini:',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B46C1),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _expressionResult.isEmpty
                      ? 'Unggah atau ambil foto wajahmu, dan biarkan aplikasi menebak ekspresimu.'
                      : 'Hasil deteksi: $_expressionResult',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Color(0xFFF5F3FF), // solid soft purple, sama dengan box lain
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: _imageFile != null
            ? Stack(
                children: [
                  Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageFile = null;
                          _expressionResult = '';
                          _expressionEmoji = '';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B46C1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 40,
                        color: Color(0xFF6B46C1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tambahkan Foto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih dari galeri atau ambil foto baru',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMoodButton(
                onTap: _getImageFromCamera,
                icon: Icons.camera_alt_rounded,
                label: 'Kamera',
                color: const Color(0xFFEC4899),
                bgColor: const Color(0xFFFDF2F8),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildMoodButton(
                onTap: _getImageFromGallery,
                icon: Icons.photo_library_rounded,
                label: 'Galeri',
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _imageFile != null && !_isAnalyzing ? _detectExpression : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              disabledBackgroundColor: const Color(0xFFE5E7EB),
            ),
            child: _isAnalyzing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Menganalisis...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Deteksi Ekspresi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white, // solid, no opacity
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hapus logo, hanya emoji dan hasil
                  Text(
                    _expressionEmoji,
                    style: const TextStyle(fontSize: 54),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _expressionResult,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B46C1).withOpacity(0.09),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Ekspresi Terdeteksi',
                      style: TextStyle(
                        color: Color(0xFF6B46C1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}