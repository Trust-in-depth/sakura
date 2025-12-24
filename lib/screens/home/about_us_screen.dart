import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hakkımızda", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. KAPAK GÖRSELİ ---
            // Buraya restoranın içinden şık bir fotoğraf koyuyoruz
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80",
                        // Alternatif Sushi Görseli: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=1470&q=80"
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Resmin üzerine hafif karartma (Yazı okunabilsin diye)
                Container(height: 250, color: Colors.black.withOpacity(0.4)),
                const Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.ramen_dining, size: 60, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "SAKURA MENU",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "Japon Mutfağının İncisi",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 2. HİKAYEMİZ KARTI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Hikayemiz"),
                  const SizedBox(height: 10),
                  const Text(
                    "2015 yılında küçük bir hayalle başlayan yolculuğumuz, bugün şehrin en sevilen Japon restoranlarından biri haline geldi. \n\nAmacımız sadece yemek sunmak değil; misafirlerimize Uzak Doğu'nun mistik atmosferini, taze malzemeler ve usta şeflerimizin dokunuşlarıyla yaşatmaktır. Her sushide bir sanat, her noodle kasesinde bir sıcaklık bulacaksınız.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 3. NEDEN BİZ? (İKONLU ANLATIM) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(Icons.verified, "Taze\nMalzemeler"),
                      _buildFeatureItem(Icons.star, "Usta\nŞefler"),
                      _buildFeatureItem(Icons.clean_hands, "Hijyenik\nOrtam"),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  // --- 4. İLETİŞİM & SAATLER ---
                  _buildSectionTitle("Çalışma Saatleri & Konum"),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.access_time,
                            "Hafta İçi: 10:00 - 22:00",
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.access_time_filled,
                            "Hafta Sonu: 10:00 - 23:00",
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.location_on,
                            "Sakura Cad. No:1, Çankaya/Ankara",
                          ),
                          const Divider(),
                          _buildInfoRow(Icons.phone, "+90 550 120 45 17"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 5. FOOTER (Versiyon vb.) ---
                  const Center(
                    child: Text(
                      "Sakura Menu App v1.0.0",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Başlıklar için yardımcı widget
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 25,
          color: const Color(0xFFD81B60),
        ), // Pembe Çizgi
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Özellik ikonları için yardımcı widget
  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFD81B60).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: const Color(0xFFD81B60)),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  // Bilgi satırları için yardımcı widget
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD81B60), size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
