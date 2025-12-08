// lib/models/veiculo_model.dart
import 'package:nanoid/nanoid.dart';

class Veiculo {
  final String id;
  final String ownerId;
  final String marca;
  final String modelo;
  final String placa;
  final String? cor;
  final int createdAt;
  final int? updatedAt;
  final int? deletedAt;

  Veiculo({
    String? id, // ID é opcional no construtor, mas final na classe
    required this.ownerId,
    required this.marca,
    required this.modelo,
    required this.placa,
    this.cor,
    int? createdAt,
    this.updatedAt,
    this.deletedAt,
  })  : id = id ?? nanoid(15), // Gera ID se for nulo
        createdAt = createdAt ??
            DateTime.now().millisecondsSinceEpoch; // Gera timestamp se for nulo

  // Converte Map para Objeto
  factory Veiculo.fromJson(Map<String, dynamic> json) {
    return Veiculo(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      placa: json['placa'] as String,
      cor: json['cor'] as String?,
      createdAt: json['createdAt'] as int,
      updatedAt: json['updatedAt'] as int?,
      deletedAt: json['deletedAt'] as int?,
    );
  }

  // Converte Objeto para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
      'cor': cor,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }
}
