import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Servicio para gestionar la transmisión de video desde una Raspberry Pi
class CameraStreamService {
  final String _baseUrl;
  bool _isStreaming = false;

  CameraStreamService({required String baseUrl}) : _baseUrl = baseUrl;

  /// Estado actual del stream
  bool get isStreaming => _isStreaming;

  /// URL del stream HLS
  String get streamUrl =>
      '$_baseUrl/video_feed'; // Aquí debería ir la URL de HLS si tu servidor la ofrece.

  /// Iniciar el stream (puedes ampliar si tu backend implementa `/start_video`)
  Future<void> iniciarStream() async {
    try {
      _isStreaming = true;
      debugPrint('[CameraStreamService] Iniciando stream: $streamUrl');
      // Aquí puedes agregar lógica para iniciar el stream si tu backend lo permite
      // Por ejemplo, si tienes un endpoint que inicia el stream, puedes llamarlo aquí.
      // Si no, simplemente asegúrate de que la URL del stream sea correcta.
    } catch (e) {
      debugPrint('[CameraStreamService] Error al iniciar el stream: $e');
    }
    // Si en el futuro usas un endpoint para iniciar, descomenta esto:
    /*
    final url = Uri.parse('$_baseUrl/start_video');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _isStreaming = true;
      } else {
        debugPrint('No se pudo iniciar el stream: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al iniciar el stream: $e');
    }
    */
  }

  /// Detener el stream, si el backend lo permite
  Future<void> detenerStream() async {
    final url = Uri.parse('$_baseUrl/stop_video');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _isStreaming = false;
        debugPrint('[CameraStreamService] Stream detenido con éxito');
      } else {
        debugPrint(
            '[CameraStreamService] Error al detener el stream: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[CameraStreamService] Excepción al detener el stream: $e');
    }
  }
}
