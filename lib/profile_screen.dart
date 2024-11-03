import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserProvider.dart';
import 'CustomBottomNavigationBa.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  DateTime? _birthday;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadUserData(userProvider);

    // Charger l'email de connexion de FirebaseAuth
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _loginController.text = firebaseUser.email ?? ''; // Récupérer l'email de l'utilisateur
    }
  }

  void _loadUserData(UserProvider userProvider) {
    final user = userProvider.user;
    if (user != null) {
      _passwordController.text = userProvider.password ?? ''; // Affiche le mot de passe récupéré
      _addressController.text = user['adresse'] ?? '';
      _postalCodeController.text = user['codePostal']?.toString() ?? '';
      _cityController.text = user['ville'] ?? '';
      
      final anniversaire = user['anniversaire'];
      if (anniversaire != null && anniversaire is Timestamp) {
        _birthday = anniversaire.toDate();
      } else {
        _birthday = anniversaire;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _birthday = picked;
      });
    }
  }

  Future<void> _saveProfile(UserProvider userProvider) async {
    final updatedUserData = {
      'password': _passwordController.text,
      'adresse': _addressController.text,
      'codePostal': int.tryParse(_postalCodeController.text) ?? 0,
      'ville': _cityController.text,
      'anniversaire': _birthday,
    };

    await userProvider.saveUserProfile(updatedUserData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changements sauvegardés')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: userProvider.user != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _loginController,
                    readOnly: true, // Le champ login est en lecture seule
                    decoration: const InputDecoration(labelText: 'Login'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'Anniversaire'),
                        controller: TextEditingController(
                          text: _birthday != null ? _birthday!.toLocal().toString().split(' ')[0] : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(labelText: 'Code Postal'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Ville'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveProfile(userProvider),
                    child: const Text('Valider'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      userProvider.logout();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text('Se déconnecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Aucun utilisateur connecté')),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 2),
    );
  }
}
