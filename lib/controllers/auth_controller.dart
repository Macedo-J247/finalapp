// lib/controllers/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart' as FBAuth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FBAuth.FirebaseAuth _auth = FBAuth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- MÉTODOS DE AUTENTICAÇÃO ---

  // 1. Monitorar Mudanças de Estado de Autenticação
  // Retorna um Stream que emite o usuário atual sempre que o estado de login muda.
  Stream<FBAuth.User?> get userChanges => _auth.authStateChanges();

  // 2. Login de Usuário
  Future<FBAuth.UserCredential> signIn(
      {required String email, required String password}) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FBAuth.FirebaseAuthException catch (e) {
      // Re-lança a exceção para ser tratada na View (LoginView)
      throw Exception(e.message ?? 'Erro de login desconhecido.');
    }
  }

  // 3. Cadastro de Novo Usuário
  Future<FBAuth.UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 3.1. Criar a conta no Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // 3.2. Criar o objeto User com o UID do Firebase Auth
        final newUser = User(
          // UID do Firebase Auth se torna o ID do documento no Firestore
          id: firebaseUser.uid,
          name: name,
          email: email,
          password:
              password, // OBS: A senha deve ser tratada como token no backend!
          role: role,
        );

        // 3.3. Salvar o perfil inicial no Firestore
        await _db
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());
      }

      return userCredential;
    } on FBAuth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Erro de cadastro desconhecido.');
    }
  }

  // 4. Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- MÉTODOS DE PERFIL (FIRESTORE) ---

  // 5. Buscar o Perfil Completo do Usuário no Firestore
  Future<User?> fetchUserFromFirestore(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        // Usa o fromJson do seu modelo User para desserializar os dados
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      // Em caso de erro de conexão ou leitura
      print('Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }
}
