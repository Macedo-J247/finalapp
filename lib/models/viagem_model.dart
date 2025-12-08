// lib/models/viagem_model.dart
enum TripStatus { requested, accepted, inProgress, completed, cancelled }

class Viagem {
  final String id;
  final String passengerId;
  final String? driverId;
  final String origin;
  final String destination;
  final int fareCents; // Valor monetário em centavos
  final TripStatus status;
  final int requestedAt;
  final int? acceptedAt;
  final int? startedAt;
  final int? finishedAt;
  final bool paid;

  Viagem({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.origin,
    required this.destination,
    required this.fareCents,
    this.status = TripStatus.requested,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.finishedAt,
    this.paid = false,
  });

  // Converte Map para Objeto (com lógica para o enum)
  factory Viagem.fromJson(Map<String, dynamic> json) {
    // Helper para desserializar o enum
    TripStatus parseStatus(String status) {
      return TripStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TripStatus.requested,
      );
    }

    return Viagem(
      id: json['id'] as String,
      passengerId: json['passengerId'] as String,
      driverId: json['driverId'] as String?,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      fareCents: json['fareCents'] as int,
      status: parseStatus(json['status'] as String),
      requestedAt: json['requestedAt'] as int,
      acceptedAt: json['acceptedAt'] as int?,
      startedAt: json['startedAt'] as int?,
      finishedAt: json['finishedAt'] as int?,
      paid: json['paid'] as bool,
    );
  }

  // Converte Objeto para Map (com lógica para o enum)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'origin': origin,
      'destination': destination,
      'fareCents': fareCents,
      'status': status.name, // Serializa o enum como string
      'requestedAt': requestedAt,
      'acceptedAt': acceptedAt,
      'startedAt': startedAt,
      'finishedAt': finishedAt,
      'paid': paid,
    };
  }
}
