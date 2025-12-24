import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guestCountController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Tarih Seçici
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFD81B60),
            colorScheme: const ColorScheme.light(primary: Color(0xFFD81B60)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Saat Seçici
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFD81B60),
            colorScheme: const ColorScheme.light(primary: Color(0xFFD81B60)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submitAppointment() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final user = FirebaseAuth.instance.currentUser;

      // Veritabanına Yazılacak Veri
      final appointmentData = {
        'user_id': user?.uid ?? 'guest',
        'user_name': _nameController.text,
        'phone': _phoneController.text,
        'guest_count': int.parse(_guestCountController.text),
        'date': _selectedDate!.toIso8601String(), // Tarihi string olarak sakla
        'time': _selectedTime!.format(context), // Saati formatla
        'status': 'Bekliyor', // Durum
        'created_at': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .add(appointmentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Randevu talebiniz başarıyla oluşturuldu! 🌸",
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context); // Sayfayı kapat
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata oluştu: $e")));
      }
    } else if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tarih ve saat seçiniz.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Randevu Oluştur",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Sakura Lezzetleri İçin Yerini Ayırt",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD81B60),
                ),
              ),
              const SizedBox(height: 30),

              // İsim Soyisim
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("İsim Soyisim", Icons.person),
                validator: (val) =>
                    val!.isEmpty ? "Lütfen isminizi girin" : null,
              ),
              const SizedBox(height: 15),

              // Telefon
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Telefon Numarası", Icons.phone),
                validator: (val) =>
                    val!.isEmpty ? "Lütfen telefon girin" : null,
              ),
              const SizedBox(height: 15),

              // Kişi Sayısı
              TextFormField(
                controller: _guestCountController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Kişi Sayısı", Icons.people),
                validator: (val) => val!.isEmpty ? "Kişi sayısı girin" : null,
              ),
              const SizedBox(height: 15),

              // Tarih ve Saat Row'u
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFFD81B60),
                      ),
                      label: Text(
                        _selectedDate == null
                            ? "Tarih Seç"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(
                        Icons.access_time,
                        color: Color(0xFFD81B60),
                      ),
                      label: Text(
                        _selectedTime == null
                            ? "Saat Seç"
                            : _selectedTime!.format(context),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _submitAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "RANDEVUYU ONAYLA",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFD81B60)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD81B60), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
