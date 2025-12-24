import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Bu dosya zaten sende var
import 'screens/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        // Kullanıcı oturumunu dinleyen sağlayıcı
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Sakura Restaurant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // 1. Durum: Bağlantı bekleniyor (Splash ekranı gibi düşünebilirsiniz)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD81B60)),
                ),
              );
            }
            // 2. Durum: Kullanıcı verisi var (Giriş yapılmış) -> Anasayfa
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            // 3. Durum: Kullanıcı yok (Giriş yapılmamış) -> Login
            return const LoginScreen(); // Buraya kendi Login sayfanızın adını yazın
          },
        ),
      ),
    );
  }
}
