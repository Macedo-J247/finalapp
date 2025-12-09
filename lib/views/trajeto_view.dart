// lib/views/trajeto_view.dart
import 'package:flutter/material.dart';
import 'package:nanoid/nanoid.dart'; // Para gerar o ID da Viagem
import '../models/viagem_model.dart'; // Importar Viagem e TripStatus
import '../controllers/viagem_controller.dart'; // Serviço de CRUD para Viagem (a ser criado)
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Add this import
import 'dart:async'; // Required for Completer

class TrajetoView extends StatefulWidget {
  final bool isDriver; // Indica se a view está sendo usada por um motorista
  const TrajetoView({super.key, required this.isDriver});

  @override
  State<TrajetoView> createState() => _TrajetoViewState();
}

class _TrajetoViewState extends State<TrajetoView> {
  // Controladores
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _fareController = TextEditingController();
  final _seatsController = TextEditingController(); // Apenas para Motorista

  // Serviços
  final ViagemService _viagemService =
      ViagemService(); // Supondo que você criou este serviço

  bool _isLoading = false;

  // Variáveis simuladas (em um app real, viriam de um Provider ou BLoC)
  final String currentUserId = 'auth_user_id_123'; // ID do usuário logado

  // Google Maps related variables
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });

    // 1. Coleta e validação de dados
    if (_originController.text.isEmpty || _destinationController.text.isEmpty) {
      // Mostrar SnackBar de erro
      if (mounted) { // Ensure context is still valid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, defina a Origem e o Destino.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // 2. Determinar o status e construir o objeto Viagem
    final newTrip = Viagem(
      // Se fosse um app real, o ID viria do nanoid/backend ou seria gerado aqui
      id: nanoid(15),
      origin: _originController.text.trim(),
      destination: _destinationController.text.trim(),
      requestedAt: DateTime.now().millisecondsSinceEpoch,

      // Lógica Motorista vs. Passageiro
      passengerId: widget.isDriver
          ? 'PENDENTE'
          : currentUserId, // Motorista não tem passageiro definido
      driverId: widget.isDriver
          ? currentUserId
          : 'PENDENTE', // Passageiro não tem motorista definido

      fareCents: widget.isDriver
          ? (double.tryParse(_fareController.text) ?? 0) *
              100 ~/
              1 // Preço definido pelo motorista
          : 500, // Preço fixo ou calculado para passageiro (simulação)

      status: widget.isDriver
          ? TripStatus.accepted
          : TripStatus.requested, // Motorista oferece, Passageiro solicita
      paid: false,
    );

    // 3. Salvar no Firestore
    try {
      // O ViagemService precisa ter um método saveViagem que usa o FirebaseHelper
      await _viagemService.saveViagem(newTrip);
      if (!mounted) return;

      // 4. Feedback e Redirecionamento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isDriver
              ? 'Carona ofertada com sucesso! Aguardando passageiros.'
              : 'Solicitação de carona enviada! Aguardando motorista.'),
        ),
      );
      if (mounted) {
        // Volta para o Hub (onde a lista de viagens será atualizada)
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) { // Ensure context is still valid before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar a viagem: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isDriver ? 'Oferecer Carona' : 'Solicitar Carona'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Seção de Mapa (Real) ---
            SizedBox( // Changed from Container to SizedBox to constrain GoogleMap
              height: 200,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- Campos de Trajeto ---\
            TextField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origem',
                icon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino',
                icon: Icon(Icons.flag_outlined),
              ),
            ),
            const SizedBox(height: 30),

            // --- Campos Condicionais (APENAS MOTORISTA) ---
            if (widget.isDriver) ...[
              const Text('Detalhes da Oferta:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              TextField(
                controller: _fareController,
                decoration: const InputDecoration(
                  labelText: 'Preço por Passageiro (R\$)',
                  icon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _seatsController,
                decoration: const InputDecoration(
                  labelText: 'Número de Assentos Disponíveis',
                  icon: Icon(Icons.event_seat),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),
            ],

            // --- Botão de Confirmação ---
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Text(widget.isDriver
                        ? 'Publicar Carona'
                        : 'Solicitar Viagem'),
                  ),
          ],
        ),
      ),
    );
  }
}