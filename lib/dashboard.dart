import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CustomBottomNavigationBa.dart';
import 'DetailPage.dart';
import 'Vetement.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Acheter"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('vetements').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun vêtement disponible"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final vetement = Vetement.fromMap(data, doc.id);

              // Décodage de l'image base64 en Uint8List pour affichage
              Uint8List? imageBytes;
              if (vetement.imageUrl != null) {
                imageBytes = base64Decode(vetement.imageUrl!);
              }

              return ListTile(
                leading: imageBytes != null
                    ? Image.memory(imageBytes, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image),
                title: Text(vetement.titre ?? "Titre inconnu"),
                subtitle: Text("Taille: ${vetement.taille ?? "N/A"}"),
                trailing: Text("\$${vetement.prix ?? "N/A"}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(vetement: vetement),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}
