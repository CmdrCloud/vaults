import 'package:flutter/material.dart';
import 'vehiculo.dart';
import 'api_service.dart';
import 'pantalla_detalle.dart';

class PantallaLista extends StatelessWidget {
    const PantallaLista({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Vehiculos'),
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
            ),
            // FutureBuilder escucha el Future de obtenerVehiculos().
            // El tipo del Future se indica entre los simbolos < y >.
            body: FutureBuilder<List<Vehiculo>>(
                future: ApiService().obtenerVehiculos(),
                builder: (context, snapshot) {

                    // Estado 1: el Future esta en curso, aun no hay resultado.
                    if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                    }

                    // Estado 2: el Future termino con un error.
                    // snapshot.error contiene el mensaje del Exception.
                    if (snapshot.hasError) {
                        return Center(
                            child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                    'Error al cargar vehiculos:
${snapshot.error}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.red),
                                ),
                            ),
                        );
                    }

                    // Estado 3: el Future termino con datos exitosamente.
                    // snapshot.data! tiene el valor. El ! indica que sabemos
                    // que no es null porque ya verificamos hasData con hasError.
                    final vehiculos = snapshot.data!;

                    if (vehiculos.isEmpty) {
                        return const Center(
                            child: Text('No hay vehiculos registrados'));
                    }

                    return ListView.builder(
                        itemCount: vehiculos.length,
                        itemBuilder: (ctx, i) {
                            final v = vehiculos[i];
                            return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                elevation: 3,
                                child: ListTile(
                                    leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.blue[800],
                                        child: Text(v.marca[0],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold)),
                                    ),
                                    title: Text(
                                        '${v.marca} ${v.modelo}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                        'Bs. ${v.precio.toStringAsFixed(2)}'),
                                    trailing: Chip(
                                        label: Text(v.estado,
                                            style: const TextStyle(
                                                fontSize: 11)),
                                        backgroundColor:
                                            v.estado == 'Disponible'
                                                ? Colors.green[100]
                                                : Colors.orange[100],
                                    ),
                                    onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    PantallaDetalle(
                                                        vehiculo: v)));
                                    },
                                ),
                            );
                        },
                    );
                },
            ),
        );
    }
}
