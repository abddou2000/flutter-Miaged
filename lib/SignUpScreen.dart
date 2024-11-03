import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'UserProvider.dart';
import 'dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Authentification avec Firebase Auth
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text, password: _passwordController.text);

        final user = userCredential.user;
        if (user != null) {
          // Récupérer les données de l'utilisateur depuis Firestore
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final userData = userDoc.data();

          if (userData != null) {
            // Stocker les données de l'utilisateur dans UserProvider
            final userProviderData = {
              ...userData,
              'login': _emailController.text, // Stocker le login
              'password': _passwordController.text, // Stocker le password
            };
            
            Provider.of<UserProvider>(context, listen: false).setUser(user.uid, userProviderData);

            // Afficher les informations dans la console
            print('--- Informations de l\'utilisateur après connexion ---');
            print('UID : ${user.uid}');
            print('Login (Email) : ${_emailController.text}');
            print('Password : ${_passwordController.text}');
            print('Données utilisateur Firestore : $userProviderData');
            print('------------------------------------------------------');

            // Naviguer vers le tableau de bord
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Dashboard()),
            );
          } else {
            _showMessage('Utilisateur non trouvé dans la base de données.');
          }
        }
      } catch (e) {
        _showMessage('Erreur de connexion : ${e.toString()}');
      }
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Login'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre Login';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
