// lib/views/login_view.dart

import 'package:flutter/material.dart';
import 'hub_view.dart';
import 'signup_view.dart';
import '../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Autenticar com o Firebase Auth
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // A busca do userProfile (Ponto 2) foi REMOVIDA
      // O HubView fará o carregamento do perfil no initState

      if (mounted) {
        // Redirecionar para o Hub após o sucesso
        // O AuthWrapper no main.dart garante que o HubView será carregado corretamente.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HubView()),
        );
      }
    } catch (e) {
      setState(() {
        // Simplifiquei a exibição da mensagem de erro
        _errorMessage = e.toString().contains('user-not-found') ||
                e.toString().contains('wrong-password')
            ? 'Usuário ou senha incorretos.'
            : 'Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo de E-mail
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Campo de Senha
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            // Mensagem de Erro
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),
            // Botão de Login
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Entrar'),
                  ),
            const SizedBox(height: 20),
            // Link para Cadastro
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignupView()),
                );
              },
              child: const Text('Não tem conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}
