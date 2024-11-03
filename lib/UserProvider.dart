import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User? _firebaseUser;
  Map<String, dynamic>? _userData;
  String? _password; // Ajout du mot de passe temporaire

  UserProvider() {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    if (_firebaseUser != null) {
      _fetchUserData();
    }
  }

  // Getter pour accéder aux données utilisateur
  Map<String, dynamic>? get user => _userData;
  String? get password => _password;

  // Méthode pour définir les données utilisateur manuellement
  void setUser(String userId, Map<String, dynamic> userData) {
    _userData = userData;
    _password = userData['password']; // Stocke temporairement le mot de passe
    notifyListeners();
  }

  // Récupère les informations utilisateur de Firestore
  Future<void> _fetchUserData() async {
    if (_firebaseUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .get();
      _userData = userDoc.data();
      _password = _userData?['password'];
      notifyListeners();
    }
  }

  // Enregistre les modifications du profil utilisateur
  Future<void> saveUserProfile(Map<String, dynamic> updatedData) async {
    if (_firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseUser!.uid)
          .update(updatedData);
      _userData = {...?_userData, ...updatedData};
      _password = updatedData['password'];
      notifyListeners();
    }
  }

  // Déconnecte l'utilisateur
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _firebaseUser = null;
    _userData = null;
    _password = null;
    notifyListeners();
  }
}
