import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:path/path.dart' as path;
// import 'package:path_provider/path_provider.dart';
import 'result_screen.dart';

// Variabel global untuk daftar kamera harus tetap di sini
late List<CameraDescription> cameras;

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  // Tema warna pink-ish girly
  static const Color darkPink = Color(0xFFE91E63); // Deeper Pink for accents
  static const Color primaryPink = Color(0xFFF8BBD0); // Light Pink
  static const Color softWhite = Color(0xFFFFF8F9); // Off-white

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    // Pastikan cameras sudah diinisialisasi sebelum digunakan
    if (cameras.isEmpty) {
        cameras = await availableCameras();
    }
    
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<String> _ocrFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text;
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      if (!mounted) return;
      
      // Tampilkan SnackBar yang lebih cantik
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.auto_fix_high, color: primaryPink),
              SizedBox(width: 8),
              Text('Memproses teks ajaib, sebentar ya...', style: TextStyle(color: softWhite)),
            ],
          ),
          backgroundColor: darkPink.withOpacity(0.9),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating, // Tampilan mengambang
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Ambil foto
      final XFile image = await _controller!.takePicture();

      // Proses OCR
      final ocrText = await _ocrFromFile(File(image.path));

      if (!mounted) return;
      // Pindah ke ResultScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ocrText: ocrText)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! Ada error saat memproses: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        backgroundColor: softWhite,
        appBar: AppBar(
          title: const Text('Kamera OCR', style: TextStyle(color: Colors.white)),
          backgroundColor: darkPink,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: darkPink),
        ),
      );
    }

    // Hitung ukuran layar untuk penempatan tombol yang responsif
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: softWhite, // Latar belakang utama
      appBar: AppBar(
        title: const Text(
          'Jendela Kamera Ajaib',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkPink,
        elevation: 6.0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Pratinjau Kamera (diperluas)
          SizedBox(
            width: size.width,
            height: size.height,
            child: CameraPreview(_controller!),
          ),

          // 2. Overlay Bingkai Fokus Lucu (Opsional, untuk kesan girly)
          Positioned.fill(
            child: Center(
              child: Container(
                width: size.width * 0.8,
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryPink, width: 3.0),
                  borderRadius: BorderRadius.circular(15.0),
                  // Tambahkan bayangan lembut
                  boxShadow: [
                    BoxShadow(
                      color: darkPink.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Posisikan Teks di sini',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      backgroundColor: Colors.black38,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4.0)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
        ],
      ),
      // Tombol Aksi Utama menggunakan FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        // Menggunakan tombol yang lebih besar dan menarik
        child: FloatingActionButton.extended(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera_alt, size: 28),
          label: const Text(
            'Ambil Foto & Scan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: darkPink,
          foregroundColor: Colors.white,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: primaryPink, width: 3), // Border pink muda
          ),
        ),
      ),
    );
  }
}