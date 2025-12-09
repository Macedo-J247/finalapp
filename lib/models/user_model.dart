// lib/models/user_model.dart
class User {
  String? id; // ID é opcional antes de ser salvo no Auth/Firestore
  String name;
  String email;
  String? password; // Made password field nullable
  String role; // 'passageiro' ou 'motorista'
  int? veiculoId; // ID do Veículo associado (se for motorista)
  double? avaliacao; // Média de avaliação (e.g., 4.7)
  int? totalAvaliacoes; // Contagem de avaliações

  User({
    this.id,
    required this.name,
    required this.email,
    this.password, // Adjusted constructor to accept nullable password
    required this.role,
    this.veiculoId,
    this.avaliacao,
    this.totalAvaliacoes,
  });

  // Converte Map para Objeto (Deserialização - Leitura do Firestore)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?, // Adjusted fromJson to handle nullable password
      role: json['role'] as String,
      veiculoId: json['veiculoId'] as int?,
      // É importante garantir que o double seja tratado corretamente
      avaliacao: (json['avaliacao'] as num?)?.toDouble(),
      totalAvaliacoes: json['totalAvaliacoes'] as int?,
    );
  }

  // Converte Objeto para Map (Serialização - Escrita no Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': null, // Set password to null when converting to JSON for Firestore
      'role': role,
      'veiculoId': veiculoId,
      'avaliacao': avaliacao,
      'totalAvaliacoes': totalAvaliacoes,
    };
  }
}