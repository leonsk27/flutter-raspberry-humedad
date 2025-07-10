import 'package:best_flutter_ui_templates/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ControllersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'controllers';
  final String _humedadUid = 'sensor_humidity';
  final String _aspersorUid = "switch_sprinkler";
  final String _historialPath = "sprinkler_history";

  /// Cambiar el estado del sensor (true/false)
  Future<void> setSensorHumidityStatus(bool active) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(_humedadUid)
          .update({'status': active});
      print("✅ Estado de 'sensor_humidity' actualizado: $active");
    } catch (e) {
      print("❌ Error al actualizar el estado del sensor: $e");
    }
  }

  /// Escuchar cambios en el campo "value"
  void listenToSensorValue(void Function(int value) onValueChanged) {
    _firestore
        .collection(_collectionPath)
        .doc(_humedadUid)
        .snapshots()
        .listen((snapshot) {
      final data = snapshot.data();
      if (data != null && data['value'] is int) {
        onValueChanged(data['value']);
        print("📡 Valor actualizado del sensor: ${data['value']}");
      }
    });
  }

  void aspersor(bool active) async {
    await _firestore
        .collection(_collectionPath)
        .doc("switch_sprinkler")
        .update({"status": active});
  }

  void setHistorialNuevo() async {
    try {
      final userUid = AuthService().user_uid;
      final sensorHumedadSnapshot =
          await _firestore.collection(_collectionPath).doc(_humedadUid).get();
      final litrosRiegoSnapshot =
          await _firestore.collection(_collectionPath).doc(_aspersorUid).get();

      print("USER_UID------$userUid");
      print("HUMEDAD------${sensorHumedadSnapshot.data()?['value']}");
      print("LITROS DE RIEGO------${litrosRiegoSnapshot.data()?['value']}");
      final humedad =
          (sensorHumedadSnapshot.data()?['value'] as num).toDouble();
      final litros = (litrosRiegoSnapshot.data()?['value'] as num).toDouble();
      final result = await _firestore.collection(_historialPath).add({
        "user_uid": userUid,
        "liters": litros,
        "humidity": humedad,
        "date": Timestamp.now()
      });
      print("REGISTRO EXITOSO");
    } catch (e) {
      print("Error al tener constancia de riegos: $e");
    }
  }
}
