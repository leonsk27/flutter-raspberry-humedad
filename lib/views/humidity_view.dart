import 'package:best_flutter_ui_templates/services/humidity_service.dart';
import 'package:best_flutter_ui_templates/services/controllers_service.dart';
import 'package:flutter/material.dart';

class HumidityView extends StatefulWidget {
  final AnimationController? animationController;

  const HumidityView({super.key, this.animationController});

  @override
  State<HumidityView> createState() => _HumidityViewState();
}

class _HumidityViewState extends State<HumidityView>
    with TickerProviderStateMixin {
  final HumidityService _humidityService = HumidityService();
  final ControllersService _sensorsService = ControllersService();
  Animation<double>? animation;
  int humedad = 0;
  bool isSprinklerActive = false;
  bool isSavingHistorial = false;
  @override
  void initState() {
    super.initState();

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: widget.animationController!, curve: Curves.fastOutSlowIn));
    _sensorsService.listenToSensorValue((newHumidity) {
      if (mounted) {
        setState(() {
          humedad = newHumidity.clamp(0, 100);
        });
        widget.animationController?.forward(from: 0.0);
      }
    });
    _cargarHumedad();
  }

  Future<void> _cargarHumedad() async {
    _sensorsService.setSensorHumidityStatus(true);
    final valor = await _humidityService.getHumidity();
    if (valor != null && mounted) {
      setState(() {
        humedad = valor.clamp(0, 100);
      });
      widget.animationController?.forward(from: 0.0);
    }
  }

  Future<void> _toggleSplinker(bool state) async {
    setState(() {
      isSprinklerActive = state;
    });

    _sensorsService.aspersor(state);

    if (!state) {
      setState(() {
        isSavingHistorial = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      _sensorsService.setHistorialNuevo();
      if (mounted) {
        setState(() {
          isSavingHistorial = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          "Guardado exitosamente!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (context, child) {
        final fillPercent = (humedad / 100) * animation!.value;

        return Scaffold(
          appBar: AppBar(title: const Text("Nivel de Humedad")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withAlpha(25),
                      ),
                      child: Icon(Icons.opacity,
                          size: 100, color: Colors.grey.withAlpha(50)),
                    ),
                    ClipPath(
                      clipper: _DropClipper(fillPercent),
                      child: Container(
                        height: 150,
                        width: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyanAccent.withAlpha(200),
                        ),
                        child: const Icon(Icons.opacity,
                            size: 100, color: Colors.cyan),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "$humedad%",
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _cargarHumedad,
                  child: const Text("Actualizar"),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Aspersor",
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: isSprinklerActive,
                          onChanged: (value) {
                            _toggleSplinker(value);
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    if (isSavingHistorial)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DropClipper extends CustomClipper<Path> {
  final double fillPercent;

  _DropClipper(this.fillPercent);

  @override
  Path getClip(Size size) {
    final height = size.height * (1 - fillPercent);
    return Path()..addRect(Rect.fromLTRB(0, height, size.width, size.height));
  }

  @override
  bool shouldReclip(_DropClipper oldClipper) =>
      oldClipper.fillPercent != fillPercent;
}
