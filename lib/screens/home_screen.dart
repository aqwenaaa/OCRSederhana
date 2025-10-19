import 'package:flutter/material.dart';
import 'scan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema warna pink-ish girly
    const Color primaryPink = Color(0xFFF8BBD0); // Light Pink
    const Color darkPink = Color(0xFFE91E63);   // Deeper Pink for accents
    const Color softWhite = Color(0xFFFFF8F9); // Off-white for background elements

    // Ganti dengan nama Anda
    const String myName = "Aqueena Regita Hapsari"; 

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selamat Datang di Aplikasi Scan!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Pacifico', // Contoh font girly (perlu ditambahkan di pubspec.yaml)
            fontSize: 22,
          ),
        ),
        backgroundColor: darkPink,
        elevation: 6.0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [softWhite, primaryPink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Icon lucu bertema pink
                const Icon(
                  Icons.favorite, // Atau Icons.stars, Icons.bubble_chart
                  size: 120,
                  color: darkPink,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Halo, Bestie!', // Tulisan welcoming
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: darkPink,
                    fontFamily: 'GreatVibes', // Contoh font (perlu ditambahkan di pubspec.yaml)
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Siap untuk menjelajahi keajaiban pemindaian teks dengan OCR (Optical Character Recognition) Sederhana?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 50),
                        Text(
                          'Tips: pastikan pencahayaan cukup agar hasil OCR makin akurat.',
                          style: TextStyle(
                            color: Colors.black.withOpacity(.45),
                            fontSize: 12.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    );
                  },
                  icon: const Icon(Icons.camera_alt, size: 30),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      'Mulai Petualangan Scan!',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: darkPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                  ),
                ),
                
                const SizedBox(height: 100), // Jarak ke copyright
                

                // Teks copyright dengan nama Anda
                Text(
                  '© ${DateTime.now().year} Dibuat dengan Cinta oleh $myName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}