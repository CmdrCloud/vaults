class Reserva {
    final int    id;
    final String fecha;
    final String nombreCliente;
    final String telefonoCliente;
    final String estadoReserva;
    // Datos del vehiculo incluidos en la respuesta del JOIN de get_reservas.php
    final int    idVehiculo;
    final String placa;
    final String marca;
    final String modelo;
    final double precio;
    final String foto;

    const Reserva({
        required this.id,
        required this.fecha,
        required this.nombreCliente,
        required this.telefonoCliente,
        required this.estadoReserva,
        required this.idVehiculo,
        required this.placa,
        required this.marca,
        required this.modelo,
        required this.precio,
        required this.foto,
    });

    factory Reserva.fromJson(Map<String, dynamic> mapa) {
        return Reserva(
            id:              mapa['id'],
            fecha:           mapa['fecha'],
            // Los nombres en el mapa coinciden exactamente con los alias del SELECT en get_reservas.php
            nombreCliente:   mapa['nombre_cliente'],
            telefonoCliente: mapa['telefono_cliente'],
            estadoReserva:   mapa['estado_reserva'],
            idVehiculo:      mapa['id_vehiculo'],
            placa:           mapa['placa'],
            marca:           mapa['marca'],
            modelo:          mapa['modelo'],
            precio:          double.parse(mapa['precio']),
            foto:            mapa['foto'] ?? '',
        );
    }
}
