import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // Çeviri için eklendi
import '../../providers/cart_provider.dart';
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

  // KATEGORİ LİSTESİ - Başlıklar artık JSON anahtarlarıyla eşleşiyor
  final List<Map<String, String>> categories = [
    {
      'title': 'cat_appetizers', // JSON'daki anahtar: "BAŞLANGIÇLAR"
      'subtitle': 'Appetizers / 前菜 – Zensai',
      'dbValue': 'Başlangıçlar(Zensai / 前菜)',
      'image':
          'https://images.unsplash.com/photo-1625938146369-adc83368bda7?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'cat_soups', // JSON'daki anahtar: "ÇORBALAR"
      'subtitle': 'Soups / 汁物 – Shirumono',
      'dbValue': 'Çorbalar (Soups / 汁物)',
      'image':
          'https://images.unsplash.com/photo-1594756202469-9ff9799b2e4e?auto=format&fit=crop&q=80&w=500',
    },
    {
      'title': 'cat_sushi',
      'subtitle': '寿司・刺身',
      'dbValue': 'sushi/sashimi (寿司/刺身)',
      'image':
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'cat_ramen',
      'subtitle': '麺類 – Menrui',
      'dbValue': 'ramen/noodle (麺類/Menrui)',
      'image':
          'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'cat_mains',
      'subtitle': 'Main Dishes / 主菜 – Shusai',
      'dbValue': 'ana yemekler (Main Dishes / 主菜)',
      'image':
          'https://images.unsplash.com/photo-1552611052-33e04de081de?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'cat_rice',
      'subtitle': 'Rice Dishes / ご飯 – Gohan',
      'dbValue': 'pirinç/bowl (Rice Dishes / ご飯)',
      'image':
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?auto=format&fit=crop&q=80&w=400',
    },
    {
      'title': 'cat_desserts',
      'subtitle': 'Desserts / 甘味 – Kanmi',
      'dbValue': 'tatlılar (Desserts / 甘味)',
      'image':
          'https://images.unsplash.com/photo-1563805042-7684c019e1cb?auto=format&fit=crop&q=80&w=500',
    },
    {
      'title': 'cat_drinks',
      'subtitle': 'Drinks / 飲み物 – Nomimono',
      'dbValue': 'içecekler (Drinks / 飲み物)',
      'image':
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&q=80&w=400',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Tema uyumluluğu için renkler
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = const Color(0xFFD81B60);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          "app_name".tr(), // "SAKURA" çevirisi
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: isDark ? Colors.white : Colors.black,
                size: 30,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: NavigationDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "categories".tr(), // "Kategoriler" çevirisi
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuScreen(
                            categoryTitle: cat['title']!
                                .tr(), // Başlığı çevirerek gönderiyoruz
                            categoryDbValue:
                                cat['dbValue']!, // Veritabanı değerini sabit gönderiyoruz
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
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
                                    cat['title']!.tr(), // Kategori ismini çevir
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat['subtitle']!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
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
          if (cart.items.isEmpty) return const SizedBox.shrink();

          return FloatingActionButton.extended(
            backgroundColor: themeColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "${cart.items.length} ${"items".tr()} - ${cart.totalPrice}₺",
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
