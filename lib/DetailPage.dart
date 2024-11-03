import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Vetement.dart';
import 'CustomBottomNavigationBa.dart';

class DetailPage extends StatelessWidget {
  final Vetement vetement;

  const DetailPage({super.key, required this.vetement});

  Future<void> _ajouterAuPanier(Vetement vetement) async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Panier')
        .add({
      'titre': vetement.titre,
      'categorie': vetement.categorie,
      'marque': vetement.marque,
      'taille': vetement.taille,
      'prix': vetement.prix,
      'imageUrl': vetement.imageUrl, // Stockage de l'image en base64
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vetement.titre ?? 'Détail du vêtement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: vetement.imageUrl != null
                  ? Image.memory(
                      base64Decode(vetement.imageUrl!), // Décodage de base64 pour affichage
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              vetement.titre ?? "Titre inconnu",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text("Catégorie: ${vetement.categorie ?? "Non spécifiée"}"),
            const SizedBox(height: 8),
            Text("Taille: ${vetement.taille ?? "Non spécifiée"}"),
            const SizedBox(height: 8),
            Text("Marque: ${vetement.marque ?? "Non spécifiée"}"),
            const SizedBox(height: 8),
            Text("Prix: \$${vetement.prix ?? "Non spécifié"}"),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Retour à la liste
                  },
                  child: const Text('Retour'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _ajouterAuPanier(vetement);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vêtement ajouté au panier')),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Ajouter au panier'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}
