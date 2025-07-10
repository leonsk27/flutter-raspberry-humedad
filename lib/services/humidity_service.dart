import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class HumidityService {
  // final String baseUrl = "http://192.168.0.235:5000/humedad";
  final String baseUrl = "http://192.168.9.10:5000/humedad";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<int?> getHumidity() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/humedad'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['humedad']; // se espera: { "humedad": 53 }
      }
      return null;
    } catch (e) {
      print("Error al obtener humedad: $e");
      return null;
    }
  }

  Future<int?> testHumedad() async {
    final random = Random();
    await Future.delayed(const Duration(milliseconds: 500));
    return random
        .nextInt(101); // Simulación de un valor de humedad para pruebas
  }
}
