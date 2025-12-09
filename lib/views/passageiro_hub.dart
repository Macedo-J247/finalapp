// lib/widgets/passageiro_hub.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/trajeto_view.dart';

class PassageiroHub extends StatelessWidget {
  final User user;
  const PassageiroHub({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Bem-vindo, ${user.name}! Status: Passageiro',
              style: const TextStyle(fontSize: 18)),
        ),

        // Botão principal para pedir carona
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.map),
            label: const Text('Solicitar uma Carona'),
            onPressed: () {
              // Navega para a tela de definição de trajeto (como passageiro)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const TrajetoView(isDriver: false)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(20),
            ),
          ),
        ),

        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Suas Viagens Ativas/Próximas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        const Expanded(
          child: Center(
            child: Text('Lista de viagens em andamento ou histórico aqui...'),
          ),
        ),
      ],
    );
  }
}
