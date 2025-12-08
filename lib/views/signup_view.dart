// lib/views/signup_view.dart
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'hub_view.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Variáveis de estado para o formulário
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = 'passageiro'; // Valor padrão

  // Opções para o seletor de função
  final List<String> _roles = ['passageiro', 'motorista'];

  Future<void> _handleSignup() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validação básica
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        // Navegar para o Hub principal após o registro e login automáticos
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HubView()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('email-already-in-use')
            ? 'Este e-mail já está em uso.'
            : e.toString();
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
      appBar: AppBar(title: const Text('Criar Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Campo Nome
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome Completo'),
            ),
            const SizedBox(height: 20),
            // Campo E-mail
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            // Campo Senha
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 30),

            // Seletor de Função (Role)
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Eu sou um...',
                border: OutlineInputBorder(),
              ),
              value: _selectedRole,
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child:
                      Text(role == 'passageiro' ? 'Passageiro' : 'Motorista'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 30),

            // Mensagem de Erro
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ),

            // Botão de Cadastro
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text('Cadastrar'),
                  ),
            const SizedBox(height: 20),
            // Link para Login
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Volta para a tela de Login
              },
              child: const Text('Já tenho conta. Fazer login'),
            ),
          ],
        ),
      ),
    );
  }
}
