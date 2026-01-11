import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart'; // Çeviri için eklendi
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

  final Color _themeColor = const Color(0xFFD81B60);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 25; i++) {
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
      size: _random.nextDouble() * 15 + 10,
      speed: _random.nextDouble() * 2 + 0.5,
      rotation: _random.nextDouble() * 2 * math.pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Tema kontrolü
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // KATMAN 1: Arka Plan
          Positioned.fill(
            child: Image.asset(
              'assets/images/Background.webp',
              fit: BoxFit.cover,
            ),
          ),

          // KATMAN 2: Karartma Filtresi
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(
                isDark ? 0.6 : 0.4,
              ), // Dark modda biraz daha koyu
            ),
          ),

          // KATMAN 3: Giriş Formu
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  // Kutu rengi temaya göre değişir
                  color: isDark
                      ? const Color(0xFF1E1E1E).withOpacity(0.95)
                      : Colors.white.withOpacity(0.9),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ramen_dining, size: 80, color: _themeColor),
                    const SizedBox(height: 10),
                    Text(
                      "app_name_".tr(), // "SAKURA"
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
                          "guest_login".tr(), // "MİSAFİR OLARAK DEVAM ET"
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
                            "or_label".tr(),
                            style: TextStyle(color: _themeColor),
                          ), // "VEYA"
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
                              "username".tr(), // "Kullanıcı Adı"
                              Icons.person,
                              (val) => username = val,
                              isDark,
                            ),
                          if (!isLoginMode) const SizedBox(height: 15),
                          _buildInput(
                            "email".tr(), // "E-posta"
                            Icons.email,
                            (val) => email = val,
                            isDark,
                          ),
                          const SizedBox(height: 15),
                          _buildInput(
                            "password".tr(), // "Şifre"
                            Icons.lock,
                            (val) => password = val,
                            isDark,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : _handleAuth,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isLoginMode
                                          ? "login_btn".tr()
                                          : "register_btn".tr(),
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
                                  ? "no_account".tr()
                                  : "have_account".tr(),
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

          // KATMAN 4: Animasyonlu Yapraklar
          _buildSakuraAnimation(size),
        ],
      ),
    );
  }

  // Yetkilendirme İşlemi
  Future<void> _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      dynamic result;
      if (isLoginMode) {
        result = await _auth.signInWithEmail(email, password);
      } else {
        result = await _auth.registerWithEmail(email, password, username);
      }
      if (result == null && mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("auth_error".tr()),
            backgroundColor: _themeColor,
          ),
        );
      }
    }
  }

  Widget _buildInput(
    String label,
    IconData icon,
    Function(String) onChanged,
    bool isDark, {
    bool obscure = false,
  }) {
    return TextFormField(
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _themeColor.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: _themeColor),
        filled: true,
        fillColor: isDark ? Colors.black26 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _themeColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      obscureText: obscure,
      onChanged: onChanged,
      validator: (val) =>
          val!.isEmpty ? '$label ${"required_field".tr()}' : null,
    );
  }

  Widget _buildSakuraAnimation(Size size) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _petals.map((petal) {
            double currentY =
                (petal.y + _controller.value * size.height * petal.speed) %
                (size.height + 100);
            return Positioned(
              left: petal.x,
              top: currentY - 100,
              child: Transform.rotate(
                angle:
                    petal.rotation +
                    _controller.value * petal.rotationSpeed * 20,
                child: Image.asset(
                  'assets/images/sakura_petal.webp',
                  width: petal.size,
                  height: petal.size,
                  color: Colors.white.withOpacity(0.8),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            );
          }).toList(),
        );
      },
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
