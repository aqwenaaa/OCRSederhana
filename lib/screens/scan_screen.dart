import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget { //FIXING CAMERA BUGS
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  // Tema warna pink-ish girly, diambil dari HomeScreen
  static const Color darkPink = Color(0xFFE91E63); // Deeper Pink for accents
  static const Color primaryPink = Color(0xFFF8BBD0); // Light Pink
  static const Color softWhite = Color(0xFFFFF8F9); // Off-white

  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  // Reuse satu instance OCR agar tidak lambat
  late final TextRecognizer _textRecognizer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  // Pastikan kamera di-reinit saat app resume
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final c = _controller;
    if (c == null) return;

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      await c.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Panggil _initCamera tanpa await agar tidak memblokir UI
      // dan tambahkan null check
      if (_controller == null || !_controller!.value.isInitialized) {
        _initCamera(reuseIndex: 0);
      }
    }
  }

  Future<void> _initCamera({int? reuseIndex}) async {
    try {
      _cameras = await availableCameras();
      if (!mounted) return;

      if (_cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.camera_alt_outlined, color: Colors.yellow),
                SizedBox(width: 8),
                Text('Kamera tidak ditemukan di perangkat.', style: TextStyle(color: Colors.white)),
              ],
            ),
            backgroundColor: darkPink,
          ),
        );
        return;
      }

      final index = (reuseIndex != null && reuseIndex < _cameras.length) ? reuseIndex : 0;
      final desc = _cameras[index];

      final controller = CameraController(
        desc,
        ResolutionPreset.medium, // bisa turunkan ke .low jika ingin lebih cepat
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // stabil di banyak device
      );

      _controller = controller;
      _initializeControllerFuture = controller.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal inisialisasi kamera: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<String> _ocrFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _textRecognizer.processImage(inputImage);
    return recognized.text;
  }

  Future<void> _takePictureAndScan() async {
    final c = _controller;
    if (c == null) return;

    try {
      await _initializeControllerFuture;

      // Ubah SnackBar menjadi tema girly
      if (mounted) {
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }

      // Pause preview saat memproses (lebih stabil di beberapa vendor)
      await c.pausePreview();

      final XFile shot = await c.takePicture();
      final String ocrText = await _ocrFromFile(File(shot.path));

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(ocrText: ocrText)),
      );

      // Lanjutkan preview setelah kembali
      if (mounted && _controller != null && _controller!.value.isInitialized) {
        await _controller!.resumePreview();
      }
    } catch (_) {
      if (!mounted) return;
      // PESAN SESUAI SOAL 2: tanpa detail error, menggunakan tema girly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.yellow),
              SizedBox(width: 8),
              Text('Pemindaian Gagal! Periksa Izin Kamera atau coba lagi.', style: TextStyle(color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    // CUSTOM LOADING SCREEN (Disesuaikan dengan tema girly)
    if (c == null || !c.value.isInitialized) {
      return Scaffold(
        backgroundColor: darkPink.withOpacity(0.9), // Latar belakang loading pink gelap
        appBar: AppBar(
          title: const Text('Kamera OCR', style: TextStyle(color: Colors.white)),
          backgroundColor: darkPink,
          elevation: 6.0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: primaryPink), // Warna loading pink muda
              const SizedBox(height: 20),
              const Text(
                'Memuat Kamera Ajaib... Harap tunggu.',
                style: TextStyle(color: softWhite, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(
                'Pastikan izin kamera sudah diberikan.',
                style: TextStyle(color: softWhite.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // TAMPILAN KAMERA UTAMA (Disesuaikan dengan tema girly)
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
          // 1. Pratinjau Kamera
          SizedBox(
            width: size.width,
            height: size.height,
            child: CameraPreview(c),
          ),

          // 2. Overlay Bingkai Fokus Lucu (dari desain sebelumnya)
          Positioned.fill(
            child: Center(
              child: Container(
                width: size.width * 0.8,
                height: size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(color: primaryPink, width: 3.0),
                  borderRadius: BorderRadius.circular(15.0),
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
      // Tombol Aksi Utama diubah dari ElevatedButton menjadi FloatingActionButton
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FloatingActionButton.extended(
          onPressed: _takePictureAndScan,
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
      // Hapus bagian padding dan ElevatedButton yang lama dari body
    );
  }
}