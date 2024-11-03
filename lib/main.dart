import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:miaged/UserProvider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'SignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignUpScreen(),
    );
  }
}
