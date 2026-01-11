import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri için eklendi

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema ve Renk Kontrolleri
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = const Color(0xFFD81B60);
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "about_us".tr(), // "Hakkımızda"
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. KAPAK GÖRSELİ ---
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1470&q=80",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(height: 250, color: Colors.black.withOpacity(0.5)),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.ramen_dining,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "app_name".tr(), // "SAKURA"
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "about_subtitle".tr(), // "Japon Mutfağının İncisi"
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
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
                  _buildSectionTitle(
                    "about_story_title".tr(),
                    themeColor,
                    textColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "about_story_text".tr(), // Hikaye metni çevirisi
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: subTextColor,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 3. NEDEN BİZ? ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureItem(
                        Icons.verified,
                        "about_feat_fresh".tr(),
                        themeColor,
                        textColor,
                      ),
                      _buildFeatureItem(
                        Icons.star,
                        "about_feat_chef".tr(),
                        themeColor,
                        textColor,
                      ),
                      _buildFeatureItem(
                        Icons.clean_hands,
                        "about_feat_hygiene".tr(),
                        themeColor,
                        textColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),

                  // --- 4. İLETİŞİM & SAATLER ---
                  _buildSectionTitle(
                    "about_info_title".tr(),
                    themeColor,
                    textColor,
                  ),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.access_time,
                            "about_hours_weekday".tr(),
                            themeColor,
                            textColor,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.access_time_filled,
                            "about_hours_weekend".tr(),
                            themeColor,
                            textColor,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.location_on,
                            "about_location".tr(),
                            themeColor,
                            textColor,
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.phone,
                            "+90 550 120 45 17",
                            themeColor,
                            textColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- 5. FOOTER ---
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

  Widget _buildSectionTitle(String title, Color themeColor, Color textColor) {
    return Row(
      children: [
        Container(width: 5, height: 25, color: themeColor),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String text,
    Color themeColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 30, color: themeColor),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color themeColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: themeColor, size: 20),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 15, color: textColor)),
          ),
        ],
      ),
    );
  }
}
