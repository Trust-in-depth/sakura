import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri paketi eklendi

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

  // Tarih Seçici (Karanlık Mod Uyumlulaştırıldı)
  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFD81B60),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFD81B60),
                  ),
                ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Saat Seçici (Karanlık Mod Uyumlulaştırıldı)
  Future<void> _pickTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFFD81B60),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFD81B60),
                  ),
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

      final appointmentData = {
        'user_id': user?.uid ?? 'guest',
        'user_name': _nameController.text,
        'phone': _phoneController.text,
        'guest_count': int.parse(_guestCountController.text),
        'date': _selectedDate!.toIso8601String(),
        'time': _selectedTime!.format(context),
        'status': 'Bekliyor',
        'created_at': FieldValue.serverTimestamp(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('appointments')
            .add(appointmentData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "appointment_success_msg".tr(),
              ), // "Randevu talebiniz başarıyla oluşturuldu! 🌸"
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("error_occured".tr() + ": $e")),
          );
        }
      }
    } else if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("date_time_error".tr()),
        ), // "Lütfen tarih ve saat seçiniz."
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "book_table".tr(), // "Randevu Oluştur"
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "appointment_header"
                    .tr(), // "Sakura Lezzetleri İçin Yerini Ayırt"
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD81B60),
                ),
              ),
              const SizedBox(height: 30),

              // İsim Soyisim
              TextFormField(
                controller: _nameController,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("full_name".tr(), Icons.person),
                validator: (val) => val!.isEmpty ? "name_required".tr() : null,
              ),
              const SizedBox(height: 15),

              // Telefon
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("phone_number".tr(), Icons.phone),
                validator: (val) => val!.isEmpty ? "phone_required".tr() : null,
              ),
              const SizedBox(height: 15),

              // Kişi Sayısı
              TextFormField(
                controller: _guestCountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: _inputDecoration("guest_count".tr(), Icons.people),
                validator: (val) => val!.isEmpty ? "count_required".tr() : null,
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
                            ? "pick_date".tr()
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: TextStyle(color: textColor.withOpacity(0.8)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(
                          color: isDark ? Colors.grey : Colors.black12,
                        ),
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
                            ? "pick_time".tr()
                            : _selectedTime!.format(context),
                        style: TextStyle(color: textColor.withOpacity(0.8)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: BorderSide(
                          color: isDark ? Colors.grey : Colors.black12,
                        ),
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
                child: Text(
                  "confirm_appointment".tr(), // "RANDEVUYU ONAYLA"
                  style: const TextStyle(
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
