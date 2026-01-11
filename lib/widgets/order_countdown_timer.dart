import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderCountdownTimer extends StatefulWidget {
  final Timestamp createdAt;
  final VoidCallback onTimeUp; // Süre bittiğinde dışarıya haber verir

  const OrderCountdownTimer({
    super.key,
    required this.createdAt,
    required this.onTimeUp,
  });

  @override
  State<OrderCountdownTimer> createState() => _OrderCountdownTimerState();
}

class _OrderCountdownTimerState extends State<OrderCountdownTimer> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  // Kalan süreyi hesaplayan ana mantık
  void _calculateRemainingTime() {
    final DateTime orderTime = widget.createdAt.toDate();
    final DateTime now = DateTime.now();
    // Sipariş zamanına 5 dakika ekleyip şu anki zamandan çıkarıyoruz
    final DateTime deadline = orderTime.add(const Duration(minutes: 5));

    _remainingTime = deadline.difference(now);

    // Süre eksiye düşerse sıfıra sabitle
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  void _startTimer() {
    // Saniyede bir tetiklenen zamanlayıcı
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _calculateRemainingTime();
          if (_remainingTime.inSeconds <= 0) {
            _timer?.cancel();
            widget.onTimeUp(); // Süre bittiğinde callback çalışır
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Bellek sızıntısını önlemek için zamanlayıcıyı kapat
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Süre bittiyse widget'ı ekrandan tamamen kaldır (veya kilit simgesi göster)
    if (_remainingTime.inSeconds <= 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_clock, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            "time_expired".tr(), // JSON'a "Süre doldu" eklemelisin
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(_remainingTime.inMinutes.remainder(60));
    final seconds = twoDigits(_remainingTime.inSeconds.remainder(60));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // Sakura pembesine veya uyarı turuncusuna uygun renk
        color: const Color(0xFFD81B60).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD81B60).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.history_toggle_off,
            size: 16,
            color: Color(0xFFD81B60),
          ),
          const SizedBox(width: 6),
          Text(
            "$minutes:$seconds",
            style: const TextStyle(
              color: Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
