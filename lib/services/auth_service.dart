import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcı durumunu anlık takip eden yayın (Stream)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Misafir Girişi (Anonim)
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print("Misafir girişi hatası: $e");
      return null;
    }
  }

  // 2. Üye Kaydı (Email + Şifre + Kullanıcı Adı)
  Future<User?> registerWithEmail(String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Kullanıcıyı veritabanına kaydet (Sipariş sayısını tutmak için)
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'total_order_count': 0, // İlk başta 0 sipariş
          'created_at': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Kayıt hatası: $e");
      return null;
    }
  }

  // 3. Üye Girişi
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Giriş hatası: $e");
      return null;
    }
  }

  // 4. Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}