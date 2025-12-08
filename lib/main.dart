// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importe a configuração específica do Firebase para o seu projeto
// OBS: Você deve gerar este arquivo usando o FlutterFire CLI
// import 'firebase_options.dart';

// Views
import 'views/login_view.dart';
import 'views/hub_view.dart';

void main() async {
  // Garante que o Flutter está pronto para inicializar serviços nativos
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializa o Firebase
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Descomente se estiver usando o firebase_options.dart
      );

  runApp(const CaronaInterestadualApp());
}

class CaronaInterestadualApp extends StatelessWidget {
  const CaronaInterestadualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carona Interestadual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      // O Widget principal que decide a rota
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. StreamBuilder para monitorar o estado de autenticação
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Exibir um indicador de carregamento enquanto verifica o estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver logado (User não é nulo)
        if (snapshot.hasData) {
          // Direciona para o Hub principal
          return const HubView();
        }

        // Se o usuário não estiver logado (User é nulo)
        // Direciona para a tela de Login
        return const LoginView();
      },
    );
  }
}
