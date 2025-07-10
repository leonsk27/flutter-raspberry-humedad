import 'package:best_flutter_ui_templates/domain/riego_registro.dart';
import 'package:best_flutter_ui_templates/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _historialPath = "sprinkler_history";
  Future<List<RiegoRegistro>> getHistorial() async {
    try {
      final user = AuthService().user_uid;
      final snapshot = await _firestore
          .collection(_historialPath)
          .where("user_uid", isEqualTo: user)
          .orderBy("date", descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return RiegoRegistro.fromJson(data);
      }).toList();
    } catch (e) {
      print("ERROR AL OBTENER HISTORIAL: $e");
      return [];
    }
  }
}
