// navigation_drawer_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../appointment/appointment_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_info_screen.dart';
import 'about_us_screen.dart';
import '/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth instansı
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          // --- 1. HEADER KISMI (PEMBE ALAN) ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            color: const Color(0xFFD81B60), // Pembe Zemin
            child: Column(
              children: [
                // NOODLE İKONU (Tıklanabilir - Profil Bilgilerine Gider)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Drawer'ı kapat
                    // Yeni oluşturduğumuz UserInfoScreen'e git
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserInfoScreen(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.ramen_dining,
                      size: 45,
                      color: Color(0xFFD81B60),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Kullanıcı ismini de buraya ekleyelim ki boş durmasın
                Text(
                  user?.displayName ?? "Misafir Kullanıcı",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Bilgileri düzenlemek için ikona tıklayınız",
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),

          // DİKKAT: Container burada bitti! Parantezi kapattık.

          // --- 2. MENÜ ELEMANLARI (LİSTE) ---
          // Artık pembe alanın dışındayız, Spacer burada çalışır.
          const SizedBox(height: 10),
          ListTile(
            leading: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: const Color(0xFFD81B60),
            ),
            title: const Text("Karanlık Mod"),
            trailing: Switch(
              value: context.watch<ThemeProvider>().isDarkMode,
              activeColor: const Color(0xFFD81B60),
              onChanged: (value) {
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month, color: Color(0xFFD81B60)),
            title: const Text("Randevu Alma"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.receipt_long, // İkonu değiştirdim
              color: Color(0xFFD81B60),
            ),
            title: const Text("Randevularım & Siparişlerim"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFFD81B60)),
            title: const Text("İletişim Bilgileri"),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("İletişim"),
                  content: const Text(
                    "Tel: +90 550 120 45 17\nAdres: Sakura Cad. No:1 Çankaya/Ankara",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tamam"),
                    ),
                  ],
                ),
              );
            },
          ),

          // Spacer, menünün geri kalanını en alta iter.
          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: const Text("Hakkımızda"),
            onTap: () {
              Navigator.pop(context); // Menüyü kapat
              // Hakkımızda sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Çıkış", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // Çıkış yaptıktan sonra login sayfasına yönlendirme main.dart içinde
              // StreamBuilder ile yapıldığı için manuel yönlendirmeye gerek kalmayabilir
              // ama drawer'ı kapatmak iyi olur.
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
