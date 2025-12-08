// lib/services/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avaliacao_model.dart';
import '../models/user_model.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Salvar a Avaliação
  Future<void> saveRating(Avaliacao rating) async {
    await _db.collection('avaliacoes').doc(rating.id).set(rating.toJson());
  }

  // 2. Atualizar a Avaliação Média do Usuário
  Future<void> updateAvgRating(String userId, int newRating) async {
    final userRef = _db.collection('users').doc(userId);

    // Usa Transaction para garantir que a leitura e a escrita sejam atômicas
    await _db.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists || userSnapshot.data() == null) {
        throw Exception("Perfil do usuário avaliado não encontrado.");
      }

      final userData = userSnapshot.data()!;

      // Mapeia para o modelo User para fácil acesso aos campos
      final user = User.fromJson(userData);

      // Calcular novas métricas
      final currentAvg = user.avaliacao ?? 0.0;
      final totalReviews = user.totalAvaliacoes ?? 0;

      // Fórmula de média ponderada (Nova Média = (Média Antiga * Total Antigo + Nova Nota) / (Total Antigo + 1))
      final newTotalScore = (currentAvg * totalReviews) + newRating;
      final newTotalReviews = totalReviews + 1;
      final newAvg = newTotalScore / newTotalReviews;

      // Atualizar o Firestore
      transaction.update(userRef, {
        'avaliacao': newAvg,
        'totalAvaliacoes': newTotalReviews,
      });
    });
  }
}
