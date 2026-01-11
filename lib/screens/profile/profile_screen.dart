import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../widgets/order_countdown_timer.dart'; // Geri sayım widget'ınız
import '../cart/cart_screen.dart'; // Sepet ekranınız
import '../../providers/cart_provider.dart';
import '../../models/food_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "my_orders_appointments".tr(),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
          backgroundColor: isDark ? Colors.transparent : Colors.white,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFFD81B60),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFD81B60),
            tabs: [
              Tab(text: "appointments".tr()),
              Tab(text: "order_history".tr()),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildUserInfoCard(user, userId),
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

  // 1. ÜST BİLGİ KARTI VE OYUNLAŞTIRMA (PROGRESS BAR)
  Widget _buildUserInfoCard(User? user, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        int orderCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Container(
          padding: const EdgeInsets.all(20),
          color: const Color(0xFFD81B60),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: Text(
                  (user?.displayName != null && user!.displayName!.isNotEmpty)
                      ? user.displayName![0].toUpperCase()
                      : "M",
                  style: const TextStyle(
                    fontSize: 28,
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
                      user?.displayName ?? "guest_user".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${"total_orders".tr()}: $orderCount",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (orderCount % 10) / 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.yellow,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderCount > 0 && orderCount % 10 == 0
                          ? "dessert_earned_msg".tr()
                          : "${10 - (orderCount % 10)} ${"more_orders_for_gift".tr()}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
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

  // 2. RANDEVU LİSTESİ
  Widget _buildAppointmentsList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("no_appointments".tr()));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            String dateStr = data['date']?.toString().split('T')[0] ?? "";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFFD81B60),
                ),
                title: Text("${data['guest_count']} ${"people".tr()}"),
                subtitle: Text(
                  "${"date".tr()}: $dateStr\n${"status".tr()}: ${data['status']}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(
                    doc.reference,
                    "confirm_cancel_appointment".tr(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 3. SİPARİŞ LİSTESİ (SAYAÇ VE DÜZENLEME)
  Widget _buildOrdersList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("error".tr()));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- KOD TARAFINDA FİLTRELEME ---
        // Veritabanından gelen tüm dokümanları alıyoruz
        final allDocs = snapshot.data?.docs ?? [];

        // Sadece 'is_visible_to_user' alanı false olmayanları ayıklıyoruz
        final visibleOrders = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Eğer alan yoksa veya true ise göster, sadece false ise gizle
          return data['is_visible_to_user'] != false;
        }).toList();

        if (visibleOrders.isEmpty) {
          return Center(child: Text("no_orders".tr()));
        }

        return ListView.builder(
          // ÇOK ÖNEMLİ: Sayı filtrelenmiş liste uzunluğu kadar olmalı
          itemCount: visibleOrders.length,
          itemBuilder: (context, index) {
            // BURADAKİ index artık visibleOrders listesiyle tam uyumlu
            final doc = visibleOrders[index];
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? createdAt = data['created_at'];

            // 5 Dakika Düzenleme Kontrolü
            bool canEdit =
                createdAt != null &&
                DateTime.now().difference(createdAt.toDate()).inMinutes < 5;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.receipt_long, color: Colors.green),
                title: Text(
                  "${(data['total_price'] ?? 0).toStringAsFixed(2)} ₺",
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${"status".tr()}: ${data['status'] ?? "Hazırlanıyor"}",
                    ),
                    if (canEdit && createdAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: OrderCountdownTimer(
                          createdAt: createdAt,
                          onTimeUp: () {
                            if (mounted) setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEdit)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFD81B60)),
                        onPressed: () => _editOrder(doc.id, data),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      // HER BUTON KENDİ DOKÜMANINA AİT REFERENCE'I GÖNDERİYOR
                      onPressed: () => _showDeleteDialog(
                        doc.reference,
                        "confirm_hide_order".tr(),
                        isSoftDelete: true,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // --- YARDIMCI FONKSİYONLAR ---

  void _editOrder(String orderId, Map<String, dynamic> data) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.clearCart();

    List items = data['items'] ?? [];
    for (var item in items) {
      cart.addToCart(
        FoodItem(
          id: item['id'] ?? "",
          name: item['name'] ?? "",
          price: (item['price'] ?? 0).toDouble(),
          imageUrl: item['imageUrl'] ?? "",
          description: "",
          category: "",
        ),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CartScreen(editOrderId: orderId, initialNote: data['order_note']),
      ),
    );
  }

  void _hideOrder(DocumentReference ref) {
    _showDeleteDialog(ref, "confirm_hide_order".tr(), isSoftDelete: true);
  }

  void _showDeleteDialog(
    DocumentReference ref,
    String message, {
    bool isSoftDelete = false,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("delete_title".tr()),
        content: Text(message),
        actions: [
          // İptal Butonu
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("cancel".tr()),
          ),
          // Silme/Gizleme Butonu
          TextButton(
            onPressed: () async {
              // 1. İşlem başlamadan önce diyaloğu hemen kapatıyoruz.
              // Bu, "deactivated widget" hatasını almanı engeller.
              Navigator.pop(ctx);

              try {
                if (isSoftDelete) {
                  // 2. Veritabanında gizleme işlemi (Soft Delete)
                  // set + merge kullanmak, alan yoksa bile oluşturulmasını sağlar.
                  await ref.set({
                    'is_visible_to_user': false,
                  }, SetOptions(merge: true));
                } else {
                  // Fiziksel silme (Randevular için)
                  await ref.delete();
                }

                // 3. İşlem başarılıysa kullanıcıya küçük bir bildirim verelim
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSoftDelete
                            ? "order_hidden_msg".tr()
                            : "item_deleted_msg".tr(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                // Hata durumunda konsola yazdır
                debugPrint("Silme işlemi sırasında hata oluştu: $e");
              }
            },
            child: Text(
              "yes_delete".tr(),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
