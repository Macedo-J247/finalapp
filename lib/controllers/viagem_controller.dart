// lib/services/viagem_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/viagem_model.dart';

class ViagemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Referência tipada para a coleção de viagens
  late final CollectionReference _viagensCollection;

  ViagemService() {
    _viagensCollection = _db.collection('viagens').withConverter<Viagem>(
          fromFirestore: (snapshot, options) =>
              Viagem.fromJson(snapshot.data()!),
          toFirestore: (viagem, options) => viagem.toJson(),
        );
  }

  // Método de salvar ou atualizar viagem
  Future<void> saveViagem(Viagem viagem) async {
    // Usa o ID da Viagem como ID do documento no Firestore
    await _viagensCollection.doc(viagem.id).set(viagem);
  }

  // Futuro: Stream para buscar viagens por status (para o Hub)
  // Stream<List<Viagem>> getDriverTrips(String driverId) {
  //   return _viagensCollection
  //       .where('driverId', isEqualTo: driverId)
  //       .where('status', whereIn: ['requested', 'accepted'])
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Viagem).toList());
  // }
}
