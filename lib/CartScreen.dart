import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'CustomBottomNavigationBa.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await _firestore.collection('users').doc(uid).collection('Panier').get();

    List<Map<String, dynamic>> items = [];
    double total = 0.0;

    for (var doc in snapshot.docs) {
      Map<String, dynamic> item = doc.data() as Map<String, dynamic>;
      item['id'] = doc.id;
      items.add(item);
      total += item['prix'] ?? 0.0;
    }

    setState(() {
      _cartItems = items;
      _totalPrice = total;
    });
  }

  Future<void> _removeFromCart(String itemId, double itemPrice) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await _firestore.collection('users').doc(uid).collection('Panier').doc(itemId).delete();

    setState(() {
      _cartItems.removeWhere((item) => item['id'] == itemId);
      _totalPrice -= itemPrice;
    });
  }

  Widget _buildImageWidget(String? imageBase64) {
    if (imageBase64 == null || imageBase64.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 100);
    }

    try {
      final bytes = base64Decode(imageBase64);
      return Image.memory(bytes, fit: BoxFit.cover, height: 100, width: 100);
    } catch (e) {
      print("Erreur de décodage de l'image : $e");
      return const Icon(Icons.error, color: Colors.red, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panier"),
      ),
      body: _cartItems.isEmpty
          ? const Center(child: Text("Votre panier est vide"))
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                final itemPrice = item['prix'] ?? 0.0;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageWidget(item['imageUrl']),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nom'] ?? 'Sans nom',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Taille : ${item['taille'] ?? 'N/A'}"),
                                  Text("Prix : ${itemPrice.toStringAsFixed(2)} €"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeFromCart(item['id'], itemPrice),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: ${_totalPrice.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          CustomBottomNavigationBar(currentIndex: 1),
        ],
      ),
    );
  }
}
