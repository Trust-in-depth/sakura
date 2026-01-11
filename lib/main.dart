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
import 'providers/theme_provider.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations', // JSON dosyalarının olduğu klasör
      fallbackLocale: const Locale('tr'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ), // Ekli olduğunu onaylayın
        StreamProvider<User?>.value(
          value: AuthService().authStateChanges,
          initialData: null,
        ),
      ],
      // Consumer ekleyerek tema değişimini dinliyoruz
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Sakura Restaurant',
            debugShowCheckedModeBanner: false,

            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            // TEMA AYARLARI BURADA BAŞLIYOR
            themeMode:
                themeProvider.themeMode, // Provider'dan gelen mod (Light/Dark)

            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: const Color(0xFFD81B60),
              scaffoldBackgroundColor: Colors.white,
              useMaterial3: true,
              // Işık modu için diğer ayarlar
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: const Color(0xFFD81B60),
              scaffoldBackgroundColor: const Color(
                0xFF121212,
              ), // Koyu gri arka plan
              useMaterial3: true,
              // Karanlık mod için diğer ayarlar
            ),

            // TEMA AYARLARI BURADA BİTİYOR
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return snapshot.hasData
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
