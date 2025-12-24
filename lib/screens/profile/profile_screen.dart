import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Tarih formatı için (pubspec.yaml'a intl ekleyin veya formatı basitleştirin)

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';

    return DefaultTabController(
      length: 2, // Randevular ve Siparişler olmak üzere 2 sekme
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Randevularım&Siparişlerim",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFFD81B60),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFD81B60),
            tabs: [
              Tab(text: "Randevularım"),
              Tab(text: "Sipariş Geçmişim"),
            ],
          ),
        ),
        body: Column(
          children: [
            // --- ÜST BİLGİ KARTI (SAYAÇ) ---
            _buildUserInfoCard(user, userId),

            // --- LİSTELER (SEKMELER) ---
            Expanded(
              child: TabBarView(
                children: [
                  _buildAppointmentsList(userId),
                  _buildOrdersList(userId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. KULLANICI BİLGİSİ VE SİPARİŞ SAYACI
  Widget _buildUserInfoCard(User? user, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        int orderCount = 0;
        if (snapshot.hasData) {
          orderCount = snapshot.data!.docs.length;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFD81B60),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName != null && user!.displayName!.isNotEmpty)
                      ? user.displayName![0].toUpperCase()
                      : "M",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Color(0xFFD81B60),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Misafir Kullanıcı",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Toplam Sipariş: $orderCount",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    // Gamification Bar (100 sipariş hedefi)
                    LinearProgressIndicator(
                      value: (orderCount % 10) / 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.yellow,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (orderCount > 0 && orderCount % 10 == 0)
                      const Text(
                        "Tebrikler! Tatlı kazandınız! 🍰",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        "${10 - (orderCount % 10)} sipariş sonra istediğin herhangi bir tatlı bizden!",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2. RANDEVU LİSTESİ VE SİLME
  Widget _buildAppointmentsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Henüz bir randevunuz yok."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Tarihi düzgün göstermek için basit işlem (date string olarak kayıtlıydı)
            // Daha şık format için intl paketi kullanılabilir.
            String dateStr = data['date'] != null
                ? data['date'].toString().split('T')[0]
                : "";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFFD81B60),
                ),
                title: Text(
                  "${data['user_name']} - ${data['guest_count']} Kişi",
                ),
                subtitle: Text(
                  "Tarih: $dateStr\nSaat: ${data['time']}\nDurum: ${data['status']}",
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteItem(
                    context,
                    doc.reference,
                    "Randevuyu iptal etmek istediğinize emin misiniz?",
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. SİPARİŞ LİSTESİ VE SİLME
  Widget _buildOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Henüz sipariş vermediniz."));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final total = data['total_price'] ?? 0;
            final items = (data['items'] as List<dynamic>?) ?? [];
            String itemNames = items
                .map((e) => "${e['name']} (x${e['quantity']})")
                .join(", ");

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.green),
                title: Text("${total.toStringAsFixed(2)} ₺"),
                subtitle: Text("$itemNames\nDurum: ${data['status']}"),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: () => _deleteItem(
                    context,
                    doc.reference,
                    "Bu sipariş kaydını silmek istediğinize emin misiniz?",
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ORTAK SİLME FONKSİYONU
  void _deleteItem(
    BuildContext context,
    DocumentReference ref,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Siliniyor"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Vazgeç"),
          ),
          TextButton(
            onPressed: () {
              ref.delete();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Kayıt silindi.")));
            },
            child: const Text("Evet, Sil", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
