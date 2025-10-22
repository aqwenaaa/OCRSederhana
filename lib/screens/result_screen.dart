import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Perlu untuk fitur copy
import 'home_screen.dart'; // <-- diperlukan untuk navigasi balik ke Home

class ResultScreen extends StatelessWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  // Tema warna pink-ish girly
  static const Color darkPink = Color(0xFFE91E63);   // Deeper Pink for accents
  static const Color primaryPink = Color(0xFFF8BBD0); // Light Pink
  static const Color softWhite = Color(0xFFFFF8F9); // Off-white

  // Fungsi untuk menampilkan SnackBar saat teks disalin
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
        backgroundColor: darkPink, // tetap sesuai UI (tidak diubah)
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (a) Soal 1.2: tampilkan teks UTUH (tanpa replaceAll)
    final displayText = ocrText.isEmpty ? 'Tidak ada teks ditemukan.' : ocrText;

    return Scaffold(
      backgroundColor: softWhite, // Latar belakang utama
      appBar: AppBar(
        title: const Text(
          'Hasil Teks Ajaib ✨',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkPink,
        elevation: 6.0,
        actions: [
          // Tombol Salin Teks (UI tetap)
          if (ocrText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy, color: primaryPink),
              tooltip: 'Salin Teks',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ocrText));
                _showCopySnackbar(context);
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header hasil
            const Text(
              'Ini dia hasilnya:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: darkPink,
              ),
            ),
            const Divider(color: primaryPink, thickness: 2, height: 20),

            // Area Teks Hasil
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
            const SizedBox(height: 16),

            // Info dan Tombol Kembali (UI asli dipertahankan)
            Center(
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),

      // (b)(c) Soal 1.2: FAB Home -> pushAndRemoveUntil ke HomeScreen
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkPink,
        child: const Icon(Icons.home),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false, // hapus semua halaman di atasnya
          );
        },
      ),
    );
  }
}
