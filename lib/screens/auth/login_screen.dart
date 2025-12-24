import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool isLoginMode = true;
  bool isLoading = false;
  String email = '', password = '', username = '';

  late final AnimationController _controller;
  final List<SakuraPetal> _petals = [];
  final math.Random _random = math.Random();

  // Tema Rengi (Butonlar için)
  final Color _themeColor = const Color(0xFFD81B60);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 25; i++) {
      // Yaprak sayısını biraz arttırdık
      _petals.add(_generateRandomPetal());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  SakuraPetal _generateRandomPetal() {
    return SakuraPetal(
      x: _random.nextDouble() * 400,
      y: -_random.nextDouble() * 200,
      size: _random.nextDouble() * 15 + 10, // Boyutları biraz küçülttük
      speed: _random.nextDouble() * 2 + 0.5,
      rotation: _random.nextDouble() * 2 * math.pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Arka plan rengine gerek kalmadı, resim kaplayacak
      body: Stack(
        children: [
          // KATMAN 1: Tam Ekran Arka Plan Görseli
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background.webp', // Tapınaklı görsel
              fit: BoxFit.cover, // Ekranı doldur
            ),
          ),

          // KATMAN 2: Karartma Filtresi (Okunabilirlik için)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4), // %40 siyah filtre
            ),
          ),

          // KATMAN 3: Giriş Formu (Merkezde)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              // Formun arkasına hafif beyaz bir kutu ekleyelim ki daha net olsun
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                    0.9,
                  ), // Hafif şeffaf beyaz kutu
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla
                  children: [
                    // Logo ve Başlık
                    Icon(Icons.ramen_dining, size: 80, color: _themeColor),
                    const SizedBox(height: 10),
                    Text(
                      "SAKURA REST",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: _themeColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Misafir Girişi
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.person_outline, color: _themeColor),
                        label: Text(
                          "MİSAFİR OLARAK DEVAM ET",
                          style: TextStyle(color: _themeColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _themeColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          setState(() => isLoading = true);
                          await _auth.signInAnonymously();
                          if (mounted) setState(() => isLoading = false);
                        },
                      ),
                    ),

                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: _themeColor.withOpacity(0.3)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "VEYA",
                            style: TextStyle(color: _themeColor),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: _themeColor.withOpacity(0.3)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Üye Formu
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!isLoginMode)
                            _buildInput(
                              "Kullanıcı Adı",
                              Icons.person,
                              (val) => username = val,
                            ),
                          if (!isLoginMode) const SizedBox(height: 15),
                          _buildInput(
                            "E-posta",
                            Icons.email,
                            (val) => email = val,
                          ),
                          const SizedBox(height: 15),
                          _buildInput(
                            "Şifre",
                            Icons.lock,
                            (val) => password = val,
                            obscure: true,
                          ),
                          const SizedBox(height: 25),

                          // Giriş/Kayıt Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeColor,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => isLoading = true);
                                        dynamic result;
                                        if (isLoginMode) {
                                          result = await _auth.signInWithEmail(
                                            email,
                                            password,
                                          );
                                        } else {
                                          result = await _auth
                                              .registerWithEmail(
                                                email,
                                                password,
                                                username,
                                              );
                                        }
                                        if (result == null && mounted) {
                                          setState(() => isLoading = false);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                "Hata oluştu, bilgilerinizi kontrol ediniz.",
                                              ),
                                              backgroundColor: _themeColor,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              child: Text(
                                isLoginMode ? "GİRİŞ YAP" : "KAYIT OL",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => isLoginMode = !isLoginMode),
                            child: Text(
                              isLoginMode
                                  ? "Hesabın yok mu? Kayıt Ol"
                                  : "Zaten üye misin? Giriş Yap",
                              style: TextStyle(color: _themeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // KATMAN 4: Düşen Yapraklar Animasyonu (En Üstte)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: _petals.map((petal) {
                  double currentY =
                      (petal.y +
                          _controller.value * size.height * petal.speed) %
                      (size.height + 100);
                  double currentRotation =
                      petal.rotation +
                      _controller.value * petal.rotationSpeed * 20;

                  return Positioned(
                    left: petal.x,
                    top: currentY - 100,
                    child: Transform.rotate(
                      angle: currentRotation,
                      child: Image.asset(
                        'assets/images/sakura_petal.webp', // Tek yaprak görseli
                        width: petal.size,
                        height: petal.size,
                        // Yapraklara hafif pembe/beyaz karışımı bir renk verelim
                        color: Colors.white.withOpacity(0.8),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    IconData icon,
    Function(String) onChanged, {
    bool obscure = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _themeColor.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: _themeColor),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _themeColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _themeColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white, // Inputların içi beyaz olsun
      ),
      obscureText: obscure,
      onChanged: onChanged,
      validator: (val) => val!.isEmpty ? '$label gerekli' : null,
      cursorColor: _themeColor,
    );
  }
}

class SakuraPetal {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double rotation;
  final double rotationSpeed;

  SakuraPetal({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}
