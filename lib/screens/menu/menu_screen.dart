import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/food_item.dart';
import '../../providers/cart_provider.dart';

class MenuScreen extends StatefulWidget {
  // Bu sayfa açılırken hangi kategoriyi göstereceğini bilmeli
  final String categoryTitle; // Örn: "BAŞLANGIÇLAR" (Başlık için)
  final String
  categoryDbValue; // Örn: "Başlangıçlar(Zensai / 前菜)" (Veritabanı sorgusu için)

  const MenuScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryDbValue,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final themeColor = const Color(0xFFD81B60); // Sakura rengimiz

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: themeColor),
          onPressed: () => Navigator.pop(context), // Geri dön
        ),
        title: Text(
          widget.categoryTitle,
          style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // FİRESTORE BAĞLANTISI (StreamBuilder)
      // Veritabanındaki değişiklikleri anlık olarak dinler
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menu_items') // Hangi koleksiyon?
            .where(
              'category',
              isEqualTo: widget.categoryDbValue,
            ) // Hangi kategori?
            .snapshots(), // Canlı yayın
        builder: (context, snapshot) {
          // 1. Durum: Veri yükleniyor mu?
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeColor));
          }

          // 2. Durum: Hata var mı?
          if (snapshot.hasError) {
            return const Center(
              child: Text("Bir hata oluştu. Lütfen tekrar deneyin."),
            );
          }

          // 3. Durum: Veri geldi ama boş mu? (O kategoride ürün yoksa)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Bu kategoride henüz ürün yok.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // 4. Durum: Veriler başarıyla geldi! Listeyi oluşturalım.
          final menuDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: menuDocs.length,
            itemBuilder: (context, index) {
              // Firestore verisini bizim FoodItem modelimize çevir
              final foodData = menuDocs[index].data() as Map<String, dynamic>;
              final foodItem = FoodItem.fromMap(foodData, menuDocs[index].id);

              // ÜRÜN KARTI TASARIMI
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SOL: Ürün Resmi
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          foodItem.imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // ORTA: Ürün Bilgileri
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItem.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              foodItem.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${foodItem.price.toStringAsFixed(2)} ₺",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SAĞ: Sepete Ekle Butonu
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () {
                              // Sepete ekleme işlemi
                              cartProvider.addToCart(foodItem);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${foodItem.name} sepete eklendi!",
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10),
                              minimumSize: const Size(40, 40),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
