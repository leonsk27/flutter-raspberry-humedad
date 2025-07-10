import 'package:best_flutter_ui_templates/domain/riego_registro.dart';
import 'package:best_flutter_ui_templates/services/history_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistroRiegoView extends StatefulWidget {
  final AnimationController? animationController;

  const RegistroRiegoView({super.key, required this.animationController});

  @override
  State<RegistroRiegoView> createState() => _RegistroRiegoViewState();
}

class _RegistroRiegoViewState extends State<RegistroRiegoView>
    with TickerProviderStateMixin {
  final List<RiegoRegistro> registros = []; //y cargarla en esta variable.
  final HistoryService _historyService = HistoryService();
  void cargarLista() async {
    final resultado = await _historyService.getHistorial();
    if (mounted)
      setState(() {
        registros.clear();
        registros.addAll(resultado);
      });
  }

  @override
  void initState() {
    super.initState();
    cargarLista();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Riegos')),
      body: AnimatedBuilder(
        animation: widget.animationController!,
        builder: (context, child) {
          return ListView.builder(
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final animation = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: widget.animationController!,
                curve: Interval((1 / registros.length) * index, 1.0,
                    curve: Curves.easeOut),
              ));

              final registro = registros[index];
              final dateFormatted =
                  DateFormat('dd/MM/yyyy HH:mm').format(registro.date);

              return SlideTransition(
                position: animation,
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.opacity, color: Colors.blue),
                    title: Text("Litros: ${registro.liters} L"),
                    subtitle: Text(
                        "Humedad: ${registro.humidity}%\nFecha: $dateFormatted"),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
