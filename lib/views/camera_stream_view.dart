import 'package:flutter/material.dart';
import 'package:best_flutter_ui_templates/services/camera_raspberry_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraStreamView extends StatefulWidget {
  const CameraStreamView({super.key, this.animationController});
  final AnimationController? animationController;
  @override
  State<CameraStreamView> createState() => _CameraStreamViewState();
}

class _CameraStreamViewState extends State<CameraStreamView>
    with TickerProviderStateMixin {
  // final CameraStreamService _cameraService =
  //     CameraStreamService(baseUrl: "http://192.168.0.235:5000");
  final CameraStreamService _cameraService =
      CameraStreamService(baseUrl: "http://192.168.9.10:5000");
  bool _cargando = false;
  late final WebViewController _webviewController;
  Animation<double>? _mainViewAnimiation;
  @override
  void initState() {
    _mainViewAnimiation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController!, curve: Curves.fastOutSlowIn));
    super.initState();
    // Inicializa WebView para Android
    _webviewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadHtmlString(
          '<html><body style="margin:0; padding:0; background:black;"><img src="${_cameraService.streamUrl}" style="width:100%; height:auto;" /></body></html>')
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Actualiza el progreso de carga si es necesario
            print("Cargando!!!: $progress%");
          },
          onPageStarted: (String url) {
            // Maneja la página iniciada si es necesario
            print("Iniciando!!!: $url");
          },
          onPageFinished: (String url) {
            print("Terminado!!!: $url");
            // Maneja la página terminada si es necesario
          },
          onWebResourceError: (WebResourceError error) {
            print("Error!!!: ${error.description}");
            // Maneja errores de recursos web si es necesario
          },
        ),
      );
  }

  Future<void> _iniciarStream() async {
    setState(() => _cargando = true);
    await _cameraService.iniciarStream();
    setState(() => _cargando = false);
  }

  Future<void> _detenerStream() async {
    setState(() => _cargando = true);
    await _cameraService.detenerStream();
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool activo = _cameraService.isStreaming;

    return AnimatedBuilder(
      animation: widget.animationController!,
      builder: (context, child) {
        return FadeTransition(
          opacity: _mainViewAnimiation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - _mainViewAnimiation!.value), 0.0),
            child: child,
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Cámara en Vivo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_cargando)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  )
                else if (activo)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: WebViewWidget(
                      controller: _webviewController,
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('Stream no iniciado'),
                  ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: !_cameraService.isStreaming && !_cargando
                          ? _iniciarStream
                          : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _cameraService.isStreaming && !_cargando
                          ? _detenerStream
                          : null,
                      icon: const Icon(Icons.stop),
                      label: const Text('Detener'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
