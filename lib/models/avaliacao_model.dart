// lib/models/avaliacao_model.dart
import 'package:nanoid/nanoid.dart';

class Avaliacao {
  final String id;
  final String tripId;
  final String fromUserId;
  final String toUserId;
  final int rating; // 1..5
  final String? comment;
  final int createdAt;

  Avaliacao({
    String? id,
    required this.tripId,
    required this.fromUserId,
    required this.toUserId,
    required this.rating,
    this.comment,
    int? createdAt,
  })  : id = id ?? nanoid(15), // Gera ID se for nulo
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch {
    // Validação da regra de negócio
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'Deve estar entre 1 e 5');
    }
  }

  // Converte Map para Objeto
  factory Avaliacao.fromJson(Map<String, dynamic> json) {
    // O construtor é chamado, executando a validação do rating
    return Avaliacao(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as int,
    );
  }

  // Converte Objeto para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
