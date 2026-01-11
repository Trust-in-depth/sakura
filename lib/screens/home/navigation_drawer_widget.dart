// navigation_drawer_widget.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri için
import '../appointment/appointment_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_info_screen.dart';
import '../../providers/theme_provider.dart'; // Yolunuzu kontrol edin
import 'about_us_screen.dart';
import 'feedback_screen.dart';

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = const Color(0xFFD81B60);

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // --- 1. HEADER KISMI ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
            ),
            color: themeColor,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
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
                    child: Icon(
                      Icons.ramen_dining,
                      size: 45,
                      color: themeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  (user != null && user.displayName != null)
                      ? user.displayName!
                      : "guest_user".tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "edit_profile_hint".tr(),
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // --- 2. TEMA VE DİL AYARLARI ---

          // Karanlık Mod Switch
          ListTile(
            leading: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: themeColor,
            ),
            title: Text("dark_mode".tr()),
            trailing: Switch(
              value: context.watch<ThemeProvider>().isDarkMode,
              activeColor: themeColor,
              onChanged: (value) =>
                  context.read<ThemeProvider>().toggleTheme(value),
            ),
          ),

          // Dil Değiştirme Seçeneği
          ListTile(
            leading: Icon(Icons.language, color: themeColor),
            title: Text(
              // Null-safe erişim ve varsayılan değer
              (context.locale?.languageCode ?? 'tr') == 'tr' ? "EN" : "TR",
              style: const TextStyle(
                color: Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              if (context.locale.languageCode == 'tr') {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('tr'));
              }
            },
          ),

          const Divider(),

          // --- 3. MENÜ LİSTESİ ---
          ListTile(
            leading: Icon(Icons.calendar_month, color: themeColor),
            title: Text("book_table".tr()),
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
            leading: Icon(Icons.receipt_long, color: themeColor),
            title: Text("my_orders_appointments".tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.phone, color: themeColor),
            title: Text("contact_info".tr()),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("contact_info".tr()),
                  content: Text("contact_details".tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("ok".tr()),
                    ),
                  ],
                ),
              );
            },
          ),

          const Spacer(),
          const Divider(),

          // --- 4. ALT MENÜ (HAKKIMIZDA, GERİ BİLDİRİM, ÇIKIŞ) ---
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: Text("about_us".tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(
              Icons.message_outlined,
              color: Colors.blueAccent,
            ),
            title: Text("feedback_title".tr()),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: Text(
              "logout".tr(),
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
