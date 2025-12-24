import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  // Sepetteki Ürünler
  final List<CartItem> _items = [];

  // Seçili Masa Numarası (Sipariş verirken lazım olacak)
  String? _tableNumber;

  List<CartItem> get items => _items;
  String? get tableNumber => _tableNumber;

  // Masa Numarasını Ayarla
  void setTableNumber(String number) {
    _tableNumber = number;
    notifyListeners();
  }

  // Sepete Ekle
  void addToCart(FoodItem food) {
    // Ürün zaten sepette var mı?
    int index = _items.indexWhere((item) => item.food.id == food.id);

    if (index >= 0) {
      // Varsa sayısını arttır
      _items[index].quantity++;
    } else {
      // Yoksa yeni ekle
      _items.add(CartItem(food: food));
    }
    notifyListeners(); // Ekranı güncelle
  }

  // Adet Azalt veya Sil
  void removeOrDecrease(FoodItem food) {
    int index = _items.indexWhere((item) => item.food.id == food.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Sepeti ve Masayı Temizle (Çıkış yaparken)
  void clearCart() {
    _items.clear();
    _tableNumber = null;
    notifyListeners();
  }

  // Toplam Tutar Hesapla
  double get totalPrice {
    return _items.fold(
      0,
      (sum, item) => sum + (item.food.price * item.quantity),
    );
  }
}
