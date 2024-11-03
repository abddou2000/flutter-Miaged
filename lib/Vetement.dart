class Vetement {
  final String id;
  final String? titre;
  final String? taille;
  final double? prix;
  final String? imageUrl; // pour stocker l'image en base64
  final String? categorie;
  final String? marque;

  Vetement({
    required this.id,
    this.titre,
    this.taille,
    this.prix,
    this.imageUrl,
    this.categorie,
    this.marque,
  });

  // Méthode pour convertir un Map en instance de Vetement
  factory Vetement.fromMap(Map<String, dynamic> data, String documentId) {
    return Vetement(
      id: documentId,
      titre: data['titre'] as String?,
      taille: data['taille'] as String?,
      prix: data['prix'] != null ? (data['prix'] as num).toDouble() : null,
      imageUrl: data['imageUrl'] as String?, // image en format base64
      categorie: data['categorie'] as String?,
      marque: data['marque'] as String?,
    );
  }
}
