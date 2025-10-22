import 'package:flutter/material.dart';
import 'package:flutter/services.dart';               // copy to clipboard
import 'package:flutter_tts/flutter_tts.dart';        // SOAL 3.1: pakai plugin TTS
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {           // SOAL 3.2a: ubah ke StatefulWidget
  final String ocrText;
  const ResultScreen({super.key, required this.ocrText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Palet warna (tetap seperti punyamu)
  static const Color darkPink   = Color(0xFFE91E63);
  static const Color primaryPink = Color(0xFFF8BBD0);
  static const Color softWhite   = Color(0xFFFFF8F9);

  // SOAL 3.2b: siapkan instance TTS
  late final FlutterTts _tts;

  @override
  void initState() {                                   // SOAL 3.2b: initState + set bahasa
    super.initState();
    _tts = FlutterTts();
    _initTts();
  }

  // SOAL 3.2b: inisialisasi TTS & atur bahasa Indonesia
  Future<void> _initTts() async {
    await _tts.setLanguage("id-ID");   // Bahasa Indonesia
    await _tts.setSpeechRate(0.45);    // opsional: kecepatan bicara
    await _tts.setPitch(1.0);          // opsional: nada
  }

  // SOAL 3.3b: fungsi untuk membacakan seluruh teks OCR
  Future<void> _speak() async {
    final text = widget.ocrText.trim();
    if (text.isEmpty) return;
    await _tts.stop();                 // hentikan bacaan sebelumnya jika ada
    await _tts.speak(text);            // bacakan teks utuh
  }

  @override
  void dispose() {                                    // SOAL 3.2c: hentikan TTS saat keluar halaman
    _tts.stop();
    super.dispose();
  }

  // SnackBar copy (UI tetap)
  void _showCopySnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: primaryPink),
            SizedBox(width: 8),
            Text('Teks ajaib berhasil disalin!', style: TextStyle(color: softWhite)),
          ],
        ),
        backgroundColor: darkPink,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (Sesuai Soal 1.2a) tampilkan teks UTUH (tanpa replaceAll)
    final displayText =
        widget.ocrText.isEmpty ? 'Tidak ada teks ditemukan.' : widget.ocrText;

    return Scaffold(
      backgroundColor: softWhite,
      appBar: AppBar(
        title: const Text(
          'Hasil Teks Ajaib ✨',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkPink,
        elevation: 6.0,
        actions: [
          if (widget.ocrText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: primaryPink),
              tooltip: 'Salin Teks',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.ocrText));
                _showCopySnackbar(context);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),

      // Konten utama
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0), // ruang bawah kecil; tombol di bottom bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ini dia hasilnya:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkPink,
              ),
            ),
            const Divider(color: primaryPink, thickness: 2, height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: primaryPink, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: darkPink.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: SelectableText(
                    displayText,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // Pindahkan tombol "Kembali & Scan Lagi" ke bottomNavigationBar (tidak bentrok dengan FAB)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text('Kembali & Scan Lagi'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),

      // SOAL 3.3a: Dua FAB vertikal (volume di atas, home di bawah)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SafeArea(
        minimum: const EdgeInsets.only(bottom: 12, right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,             // biar nempel bawah
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'ttsFab',
              backgroundColor: darkPink,
              child: const Icon(Icons.volume_up),
              onPressed: _speak,                      // SOAL 3.3b: panggil speak()
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'homeFab',
              backgroundColor: darkPink,
              child: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
