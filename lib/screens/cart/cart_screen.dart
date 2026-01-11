import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  // Düzenleme modu için opsiyonel parametreler
  final String? editOrderId;
  final String? initialNote;

  const CartScreen({super.key, this.editOrderId, this.initialNote});

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
    // Masa numarasını provider'dan çek
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final savedTable = Provider.of<CartProvider>(
        context,
        listen: false,
      ).tableNumber;
      if (savedTable != null) {
        _tableController.text = savedTable;
      }
    });
    // Eğer düzenleme modundaysak notu getir
    if (widget.initialNote != null) {
      _noteController.text = widget.initialNote!;
    }
  }

  @override
  void dispose() {
    _tableController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- SİPARİŞ İŞLEMİ (GÜNCELLEME VEYA YENİ SİPARİŞ) ---
  Future<void> _submitOrder(BuildContext context, CartProvider cart) async {
    if (_tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("table_error".tr()),
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
        'order_note': _noteController.text,
        'user_id': user?.uid ?? "guest",
        'user_name': user?.displayName ?? "Misafir",
        'total_price': cart.totalPrice,
        'status': 'Hazırlanıyor',
        'is_visible_to_user': true, // Kullanıcı sildiğinde false olacak
        'updated_at': FieldValue.serverTimestamp(),
        'items': cart.items
            .map(
              (item) => {
                'name': item.food.name,
                'price': item.food.price,
                'quantity': item.quantity,
                'id': item.food.id,
              },
            )
            .toList(),
      };

      if (widget.editOrderId != null) {
        // --- 1. DÜZENLEME MODU ---
        // Zaman kontrolü: Database'den tekrar kontrol etmek en güvenlisidir
        DocumentSnapshot oldDoc = await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.editOrderId)
            .get();

        Timestamp createdAt = oldDoc.get('created_at');
        if (DateTime.now().difference(createdAt.toDate()).inMinutes >= 5) {
          throw Exception("edit_time_expired".tr()); // "5 dakika geçti!"
        }

        await FirebaseFirestore.instance
            .collection('orders')
            .doc(widget.editOrderId)
            .update(orderData);
      } else {
        // --- 2. YENİ SİPARİŞ MODU ---
        orderData['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('orders').add(orderData);
      }

      if (mounted) {
        setState(() => isLoading = false);
        cart.clearCart(); // Sepeti boşalt

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              widget.editOrderId != null
                  ? "update_success_title".tr()
                  : "order_success_title".tr(),
            ),
            content: Text(
              widget.editOrderId != null
                  ? "update_success_msg".tr()
                  : "order_success_msg".tr(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text("ok".tr()),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains("edit_time_expired")
                  ? "edit_time_expired".tr()
                  : "error_occured".tr() + ": $e",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = const Color(0xFFD81B60);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.editOrderId != null ? "edit_order_title".tr() : "my_cart".tr(),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: cart.items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: _buildProductList(cart, isDark, themeColor, textColor),
                ),
                _buildBottomPanel(cart, isDark, themeColor, textColor),
              ],
            ),
    );
  }

  // Boş Sepet Görünümü
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            "cart_empty".tr(),
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Ürün Listesi
  Widget _buildProductList(
    CartProvider cart,
    bool isDark,
    Color themeColor,
    Color textColor,
  ) {
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final cartItem = cart.items[index];
        return Card(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.food.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
              ),
            ),
            title: Text(
              cartItem.food.name,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              "${cartItem.food.price} ₺",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => cart.removeOrDecrease(cartItem.food),
                ),
                Text(
                  "${cartItem.quantity}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: themeColor),
                  onPressed: () => cart.addToCart(cartItem.food),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Alt Panel (Masa, Not ve Buton)
  Widget _buildBottomPanel(
    CartProvider cart,
    bool isDark,
    Color themeColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
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
          TextField(
            controller: _tableController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'table_no'.tr(),
              prefixIcon: Icon(Icons.table_restaurant, color: themeColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) => cart.setTableNumber(value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'order_note_label'.tr(),
              prefixIcon: Icon(Icons.note_alt_outlined, color: themeColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "total".tr() + ":",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
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
          const SizedBox(height: 15),
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
              onPressed: isLoading ? null : () => _submitOrder(context, cart),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.editOrderId != null
                          ? "update_order_btn".tr()
                          : "confirm_order".tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
