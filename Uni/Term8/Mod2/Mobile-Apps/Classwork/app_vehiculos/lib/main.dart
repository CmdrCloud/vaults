import "package:flutter/material.dart";
import "pantalla_lista.dart";

void main() {
  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "App Vehiculos",
      home: const PantallaLista(),
    );
  }
}
