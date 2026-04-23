import 'package:flutter/material.dart';
import 'vehiculo.dart';

class PantallaDetalle extends StatelessWidget {
  // El vehiculo llega por el constructor.
  // final porque el detalle no modifica el objeto, solo lo muestra.
  final Vehiculo vehiculo;

  const PantallaDetalle({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // El titulo muestra la marca y modelo del vehiculo recibido.
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          // crossAxisAlignment.start alinea los hijos a la izquierda.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Un widget reutilizable para mostrar cada dato del vehiculo.
            _filaDato('Placa', vehiculo.placa),
            _filaDato('Marca', vehiculo.marca),
            _filaDato('Modelo', vehiculo.modelo),
            _filaDato('Precio', 'Bs. ${vehiculo.precio.toStringAsFixed(2)}'),
            _filaDato('Estado', vehiculo.estado),
            const SizedBox(height: 32),
            // Boton que ocupa todo el ancho disponible.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // pop elimina esta pantalla de la pila y vuelve a la lista.
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Volver a la lista',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metodo privado que construye una fila de etiqueta + valor.
  // Se llama con _filaDato('Marca', vehiculo.marca).
  // El guion bajo al inicio indica que es privado (solo visible en este archivo).
  Widget _filaDato(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Expanded ocupa el espacio restante en la fila.
          // flex:2 le da el doble de espacio que flex:3 al valor.
          Expanded(
            flex: 2,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(valor, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
