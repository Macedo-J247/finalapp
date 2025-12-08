// lib/views/rating_view.dart
import 'package:flutter/material.dart';
import '../models/avaliacao_model.dart';
import '../controllers/rating_controller.dart';

class RatingView extends StatefulWidget {
  final String tripId;
  final String fromUserId; // ID de quem avalia (e.g., Passageiro)
  final String toUserId; // ID de quem é avaliado (e.g., Motorista)
  final String toUserName; // Nome para exibir na tela

  const RatingView({
    super.key,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.toUserName,
  });

  @override
  State<RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<RatingView> {
  final _commentController = TextEditingController();
  final RatingService _ratingService = RatingService();
  int _currentRating = 5; // Valor padrão 5
  bool _isLoading = false;

  Future<void> _handleSubmitRating() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Criar e Salvar o objeto Avaliacao
      final newRating = Avaliacao(
        tripId: widget.tripId,
        fromUserId: widget.fromUserId,
        toUserId: widget.toUserId,
        rating: _currentRating,
        comment: _commentController.text.trim(),
        // O ID e createdAt são gerados automaticamente pelo construtor
      );

      // Salva a avaliação (documento)
      await _ratingService.saveRating(newRating);

      // 2. Atualizar a média de pontuação do perfil do motorista/passageiro avaliado
      await _ratingService.updateAvgRating(widget.toUserId, _currentRating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avaliação enviada com sucesso!')),
        );
        // Retorna ao Hub ou próxima tela
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar avaliação: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget para as estrelas
  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final ratingValue = index + 1;
        return IconButton(
          icon: Icon(
            ratingValue <= _currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              _currentRating = ratingValue;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avaliar Viagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Como você avalia ${widget.toUserName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Estrelas de Avaliação
            _buildRatingStars(),
            const SizedBox(height: 10),
            Text(
              'Nota: $_currentRating/5',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            const SizedBox(height: 40),

            // Campo de Comentário
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comentário (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // Botão de Envio
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _handleSubmitRating,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar Avaliação'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
