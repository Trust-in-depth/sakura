import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;
  final TextEditingController _tableController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedTable = Provider.of<CartProvider>(
        context,
        listen: false,
      ).tableNumber;
      if (savedTable != null) {
        _tableController.text = savedTable;
      }
    });
  }

  @override
  void dispose() {
    _tableController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final themeColor = const Color(0xFFD81B60);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sepetim", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Sepetiniz henüz boş.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 1. Ürün Listesi
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cartItem.food.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, _, __) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.food.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${cartItem.food.price} ₺",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () {
                                      cart.removeOrDecrease(cartItem.food);
                                    },
                                  ),
                                  Text(
                                    "${cartItem.quantity}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Color(0xFFD81B60),
                                    ),
                                    onPressed: () {
                                      cart.addToCart(cartItem.food);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. Alt Bilgi Alanı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // --- MASA NUMARASI ---
                      TextField(
                        controller: _tableController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Masa Numarası',
                          hintText: 'Örn: 5',
                          prefixIcon: const Icon(
                            Icons.table_restaurant,
                            color: Color(0xFFD81B60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) {
                          cart.setTableNumber(value);
                        },
                      ),

                      const SizedBox(height: 10), // Boşluk
                      // --- EKLENEN KISIM: SİPARİŞ NOTU ALANI ---
                      TextField(
                        controller: _noteController,
                        keyboardType: TextInputType.text,
                        maxLines: 2, // Biraz geniş olsun
                        decoration: InputDecoration(
                          labelText: 'Müşteri Notu (İsteğe Bağlı)',
                          hintText: 'Örn: Soğan olmasın, acı olsun...',
                          prefixIcon: const Icon(
                            Icons.note_alt_outlined, // Not ikonu
                            color: Color(0xFFD81B60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      // ------------------------------------------
                      const SizedBox(height: 20),

                      // Toplam Tutar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Toplam Tutar:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${cart.totalPrice.toStringAsFixed(2)} ₺",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Siparişi Onayla Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () => _submitOrder(context, cart),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "SİPARİŞİ ONAYLA",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _submitOrder(BuildContext context, CartProvider cart) async {
    // 1. KONTROL: Masa numarası girilmiş mi?
    if (_tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen masa numaranızı giriniz!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      final orderData = {
        'table_number': _tableController.text,
        'order_note': _noteController.text, // --- EKLENEN KISIM: NOT VERİSİ ---
        'user_id': user?.uid ?? "guest",
        'user_name': user?.displayName ?? "Misafir",
        'total_price': cart.totalPrice,
        'status': 'Hazırlanıyor',
        'created_at': FieldValue.serverTimestamp(),
        'items': cart.items.map((item) {
          return {
            'name': item.food.name,
            'price': item.food.price,
            'quantity': item.quantity,
            'id': item.food.id,
          };
        }).toList(),
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);

      if (mounted) {
        setState(() => isLoading = false);
        cart.clearCart();
        _tableController.clear();
        _noteController.clear(); // Not alanını da temizle

        // --- GÜNCELLENEN KISIM: İSTEDİĞİNİZ MESAJ ---
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Sipariş Alındı! 🍜"),
            content: const Text(
              "Talepleriniz doğrultusunda siparişiniz alındı. Afiyet olsun!",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text("Tamam"),
              ),
            ],
          ),
        );
        // ----------------------------------------------
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }
}
