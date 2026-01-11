import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri paketi eklendi

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user?.displayName != null) {
      _nameController.text = user!.displayName!;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // 1. İsim Güncelleme
      if (_nameController.text.trim() != user?.displayName) {
        await user?.updateDisplayName(_nameController.text.trim());
      }

      // 2. Şifre Güncelleme (Doluysa)
      if (_passwordController.text.isNotEmpty) {
        await user?.updatePassword(_passwordController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "profile_updated_msg".tr(),
            ), // "Bilgileriniz güncellendi! ✅"
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "error_occured".tr();
      if (e.code == 'requires-recent-login')
        msg = "relogin_required_msg"
            .tr(); // "Şifre değiştirmek için tekrar girin."
      if (e.code == 'weak-password')
        msg = "weak_password_msg".tr(); // "Şifre çok zayıf."

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = const Color(0xFFD81B60);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "profile_details_title".tr(), // "Profil Bilgilerim"
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profil Resmi
              CircleAvatar(
                radius: 50,
                backgroundColor: themeColor,
                child: Text(
                  (user?.displayName != null && user!.displayName!.isNotEmpty)
                      ? user!.displayName![0].toUpperCase()
                      : "M",
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // E-posta (Sadece Okunur)
              TextFormField(
                initialValue: user?.email,
                readOnly: true,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: "email".tr(),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // İsim Soyisim
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "full_name".tr(),
                  Icons.person_outline,
                  themeColor,
                ),
                validator: (val) => val!.isEmpty ? "name_required".tr() : null,
              ),

              const SizedBox(height: 30),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "security_section".tr(), // "Güvenlik"
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Yeni Şifre
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "new_password_label".tr(),
                  Icons.lock_outline,
                  themeColor,
                ).copyWith(hintText: "password_change_hint".tr()),
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6)
                    return "password_too_short".tr();
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Şifre Tekrar
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration(
                  "confirm_password_label".tr(),
                  Icons.lock,
                  themeColor,
                ),
                validator: (val) {
                  if (_passwordController.text.isNotEmpty &&
                      val != _passwordController.text) {
                    return "passwords_not_match".tr();
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : _updateProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "save_update_btn".tr(), // "KAYDET & GÜNCELLE"
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    Color themeColor,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: themeColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: themeColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
