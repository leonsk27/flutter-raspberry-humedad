import 'package:cloud_firestore/cloud_firestore.dart';

class RiegoRegistro {
  final DateTime date;
  final double liters;
  final double humidity;
  final String user;

  RiegoRegistro(
      {required this.date,
      required this.liters,
      required this.humidity,
      required this.user});

  factory RiegoRegistro.fromJson(Map<String, dynamic> json) {
    return RiegoRegistro(
        date: (json['date'] as Timestamp).toDate(),
        liters: (json['liters'] as num).toDouble(),
        humidity: (json['humidity'] as num).toDouble(),
        user: json["user_uid"]);
  }
}
