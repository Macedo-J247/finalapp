// lib/widgets/motorista_hub.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../views/trajeto_view.dart';

class MotoristaHub extends StatelessWidget {
  final User user;
  const MotoristaHub({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Bem-vindo, ${user.name}! Status: Motorista',
              style: const TextStyle(fontSize: 18)),
        ),

        // Botão principal para oferecer carona
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.directions_car),
            label: const Text('Oferecer Nova Carona'),
            onPressed: () {
              // Navega para a tela de definição de trajeto (como motorista)
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const TrajetoView(isDriver: true)),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
            ),
          ),
        ),

        const Divider(),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Viagens Ativas e Solicitações Pendentes:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),

        const Expanded(
          child: Center(
            child: Text('Lista de viagens em tempo real aqui...'),
          ),
        ),
      ],
    );
  }
}
