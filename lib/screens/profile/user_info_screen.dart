import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
          const SnackBar(
            content: Text("Bilgileriniz güncellendi! ✅"),
            backgroundColor: Colors.green,
          ),
        );
        // İsteğe bağlı: Güncelleme bitince sayfayı kapatabilir veya öylece bırakabilirsiniz.
        // Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Hata oluştu.";
      if (e.code == 'requires-recent-login')
        msg = "Şifre değiştirmek için lütfen çıkış yapıp tekrar girin.";
      if (e.code == 'weak-password') msg = "Şifre çok zayıf.";

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Bilgilerim",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
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
                backgroundColor: const Color(0xFFD81B60),
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

              // E-posta (Okunur Sadece)
              TextFormField(
                initialValue: user?.email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey[200],
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
                decoration: InputDecoration(
                  labelText: "Ad Soyad",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFFD81B60),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val!.isEmpty ? "İsim boş olamaz" : null,
              ),

              const SizedBox(height: 30),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Güvenlik",
                    style: TextStyle(
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
                decoration: InputDecoration(
                  labelText: "Yeni Şifre (İsteğe Bağlı)",
                  hintText: "Değiştirmek istemiyorsanız boş bırakın",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFFD81B60),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (val != null && val.isNotEmpty && val.length < 6)
                    return "En az 6 karakter olmalı";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Şifre Tekrar
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Yeni Şifre Tekrar",
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFFD81B60)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  if (_passwordController.text.isNotEmpty &&
                      val != _passwordController.text) {
                    return "Şifreler uyuşmuyor";
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
                    backgroundColor: const Color(0xFFD81B60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : _updateProfile,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "KAYDET & GÜNCELLE",
                          style: TextStyle(
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
}
