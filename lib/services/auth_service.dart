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
      // Hataları sadece print etmek yerine debug modda görebiliriz
      return null;
    }
  }

  // 2. Üye Kaydı (Email + Şifre + Kullanıcı Adı)
  Future<User?> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Kullanıcıyı veritabanına kaydet
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'role': 'user', // Varsayılan olarak her kullanıcı 'user' rolündedir
          'total_order_count': 0,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Kullanıcının Firebase Profile üzerindeki ismini de güncelleyelim
        await user.updateDisplayName(username);
      }
      return user;
    } catch (e) {
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
      return null;
    }
  }

  // 4. Çıkış Yap
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Çıkış hatası
    }
  }

  // 5. İleride Admin Paneli İçin Lazım Olacak: Kullanıcı Rolünü Çekme
  Future<String> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return doc.get('role') ?? 'user';
      }
      return 'user';
    } catch (e) {
      return 'user';
    }
  }
}
