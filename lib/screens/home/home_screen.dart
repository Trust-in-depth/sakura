import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
// Bir sonraki adımda detay sayfasını yapacağız, şimdilik placeholder duracak
import '../menu/menu_screen.dart';
import '../cart/cart_screen.dart';
import 'navigation_drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // KATEGORİ LİSTESİ
  // 'title': Ekranda görünecek isim
  // 'subtitle': Japonca alt başlık
  // 'dbValue': Firestore'da kayıtlı olan kategori ismi (Filtreleme için önemli!)
  // 'image': Temsili görsel (Senin için Unsplash linkleri hazırladım)
  final List<Map<String, String>> categories = [
    {
      'title': 'BAŞLANGIÇLAR',
      'subtitle': 'Appetizers / 前菜 – Zensai',
      'dbValue':
          'Başlangıçlar(Zensai / 前菜)', // Veritabanındaki ismin aynısı olmalı
      'image':
          'https://images.unsplash.com/photo-1625938146369-adc83368bda7?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'ÇORBALAR',
      'subtitle': 'Soups / 汁物 – Shirumono',
      'dbValue': 'Çorbalar (Soups / 汁物)',
      'image':
          'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e?auto=format&fit=crop&q=80&w=500',
    },
    {
      'title': 'SUSHI & SASHIMI',
      'subtitle': '寿司・刺身',
      'dbValue': 'sushi/sashimi (寿司/刺身)',
      'image':
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'RAMEN & NOODLE',
      'subtitle': '麺類 – Menrui',
      'dbValue': 'ramen/noodle (麺類/Menrui)',
      'image':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'ANA YEMEKLER',
      'subtitle': 'Main Dishes / 主菜 – Shusai',
      'dbValue': 'ana yemekler (Main Dishes / 主菜)',
      'image':
          'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'PİRİNÇ & BOWL',
      'subtitle': 'Rice Dishes / ご飯 – Gohan',
      'dbValue': 'pirinç/bowl (Rice Dishes / ご飯)',
      'image':
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'TATLILAR',
      'subtitle': 'Desserts / 甘味 – Kanmi',
      'dbValue': 'tatlılar (Desserts / 甘味)',
      'image':
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&q=80&w=500',
    },
    {
      'title': 'İÇECEKLER',
      'subtitle': 'Drinks / 飲み物 – Nomimono',
      'dbValue': 'içecekler (Drinks / 飲み物)',
      'image':
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&q=80&w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Profil ikonunu kaldırmak için leading'i boş bırakıyoruz veya false yapıyoruz
        automaticallyImplyLeading: false,

        // 2. Başlığı sola yaslamak için centerTitle: false yapıyoruz
        centerTitle: false,

        title: const Text(
          "SAKURA",
          style: TextStyle(
            color: Color.fromARGB(255, 230, 78, 134), // Sizin pembe tonunuz
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,

        // 3. Hamburger menüyü sağ tarafta tutmak için actions kullanıyoruz
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () {
                // Sağdan açılan menü (endDrawer) tetiklenir
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),

      // Menü sağdan açılsın isterseniz endDrawer, soldan isterseniz drawer kullanın.
      // Görselde sağda olduğu için endDrawer kullandım.
      endDrawer: const NavigationDrawerWidget(),
      // --- 3. ANA İÇERİK (KATEGORİ KARTLARI) ---
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kategoriler",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Yan yana 2 kutu
                  childAspectRatio: 0.8, // Kartların boyu eninden uzun olsun
                  crossAxisSpacing: 15, // Yatay boşluk
                  mainAxisSpacing: 15, // Dikey boşluk
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () {
                      // TIKLAMA OLAYI
                      // Burada 'dbValue' değerini sonraki sayfaya göndereceğiz
                      // Böylece sadece o kategoriye ait ürünleri çekeceğiz.
                      // --- NAVİGASYON AKTİF ---
                      // Tıklanan kategorinin başlığını ve veritabanı değerini
                      // MenuScreen sayfasına gönderiyoruz.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            categoryTitle: cat['title']!,
                            categoryDbValue: cat['dbValue']!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                cat['image']!,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: const Color(0xFFD81B60),
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (ctx, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.fastfood,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cat['title']!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat['subtitle']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty)
            return const SizedBox.shrink(); // Boşsa gösterme

          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFD81B60),
            onPressed: () {
              // Sepet Sayfasına Git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ), // import etmeyi unutma!
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "${cart.items.length} Ürün - ${cart.totalPrice}₺",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
    );
  }
}
