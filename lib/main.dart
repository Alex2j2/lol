import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE65100),
      ),
      home: const PantallaSecciones(),
    );
  }
}

class PantallaSecciones extends StatefulWidget {
  const PantallaSecciones({super.key});

  @override
  State<PantallaSecciones> createState() => _PantallaSeccionesState();
}

class _PantallaSeccionesState extends State<PantallaSecciones> {
  static const naranja = Color(0xFFE65100);
  static const fondo = Color(0xFFFFF3E0);
  static const azul = Color(0xFF1565C0); // color del enlace
  static const urlUniversidad = 'https://www.uprr.edu.mx';

  // Sección activa: 0 = Android, 1 = iOS
  int seleccion = 0;

  // Estado compartido por las dos secciones
  final TextEditingController _controller = TextEditingController();
  String nombreMostrado = '';
  bool pequena = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Cada 5 segundos la imagen cambia entre pequeña y normal
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      setState(() => pequena = !pequena);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _aceptar() {
    setState(() => nombreMostrado = _controller.text);
  }

  // Abre la página de la universidad en el navegador
  Future<void> _abrirSitio() async {
    final uri = Uri.parse(urlUniversidad);
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la página')),
      );
    }
  }

  // Mensaje al entrar a cada sección:
  // iOS usa showCupertinoDialog y Android usa showDialog.
  void _mostrarMensaje(int seccion) {
    if (seccion == 1) {
      showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Pantalla iOS'),
          content: const Text('Estás en la pantalla de iOS'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pantalla Android'),
          content: const Text('Estás en la pantalla de Android'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  // Contenido de tu pantalla. Se reutiliza en Android e iOS;
  // solo cambian el campo de texto y el botón según el estilo.
  Widget _contenido({required bool esIOS}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Texto con decoración
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: naranja, width: 2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              esIOS ? 'Mundo' : 'Hola',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: naranja,
                decoration: TextDecoration.underline,
                decorationColor: naranja,
              ),
            ),
          ),

          // 2. Imagen con tamaño animado (100 pequeña / 250 normal)
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            width: pequena ? 100 : 250,
            height: pequena ? 100 : 250,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/img/gato_meme.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),

          // 3. Entrada de texto + botón (cambia según la sección)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: esIOS
                    ? CupertinoTextField(
                        controller: _controller,
                        placeholder: 'Nombre',
                        maxLines: 1,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          border: Border.all(color: naranja),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                    : TextField(
                        controller: _controller,
                        maxLines: 1,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          floatingLabelStyle: const TextStyle(color: naranja),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: naranja),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: naranja),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: naranja, width: 2),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              esIOS
                  ? CupertinoButton(
                      color: naranja,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      onPressed: _aceptar,
                      child: const Text(
                        '✔',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: naranja,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                      ),
                      onPressed: _aceptar,
                      child: const Text('✔'),
                    ),
            ],
          ),

          // 4. Texto que muestra la variable
          Text(
            nombreMostrado,
            style: const TextStyle(fontSize: 28),
          ),

          // 5. Enlace a la página web (cambia según la sección)
          esIOS
              ? CupertinoButton(
                  onPressed: _abrirSitio,
                  child: const Text(
                    'Visitar Universidad',
                    style: TextStyle(
                      fontSize: 18,
                      color: azul,
                      decoration: TextDecoration.underline,
                      decorationColor: azul,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _abrirSitio,
                  child: const Text(
                    'Visitar Universidad',
                    style: TextStyle(
                      fontSize: 18,
                      color: azul,
                      decoration: TextDecoration.underline,
                      decorationColor: azul,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // Sección Android: estructura Material
  Widget _pantallaAndroid() {
    return Scaffold(
      key: const ValueKey('android'),
      backgroundColor: fondo,
      body: SafeArea(child: _contenido(esIOS: false)),
    );
  }

  // Sección iOS: estructura Cupertino
  Widget _pantallaIOS() {
    return Material(
      key: const ValueKey('ios'),
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        backgroundColor: fondo,
        navigationBar: const CupertinoNavigationBar(
          middle: Text('iOS'),
          backgroundColor: Color(0xFFFFE0B2),
        ),
        child: SafeArea(child: _contenido(esIOS: true)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Capa 1: la sección activa
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: seleccion == 0 ? _pantallaAndroid() : _pantallaIOS(),
          ),
        ),

        // Capa 2: selector flotante Android / iOS
        Positioned(
          left: 24,
          right: 24,
          bottom: 16,
          child: SafeArea(
            top: false,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: seleccion,
                  children: const {
                    0: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text('Android'),
                    ),
                    1: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Text('iOS'),
                    ),
                  },
                  onValueChanged: (valor) {
                    if (valor != null && valor != seleccion) {
                      setState(() => seleccion = valor);
                      _mostrarMensaje(valor);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}