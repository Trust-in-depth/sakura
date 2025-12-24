import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Kullanıcı yoksa -> Login Ekranı
    if (user == null) {
      return const LoginScreen();
    }

    // Kullanıcı varsa -> Ana Sayfa
    return const HomeScreen();
  }
}