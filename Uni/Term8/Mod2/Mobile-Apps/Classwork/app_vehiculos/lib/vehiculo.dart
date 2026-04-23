class Vehiculo {
    final int    id;
    final String placa;
    final String marca;
    final String modelo;
    final double precio;
    final String estado;
    final String foto;
    final String descripcion;

    const Vehiculo({
        required this.id,
        required this.placa,
        required this.marca,
        required this.modelo,
        required this.precio,
        required this.estado,
        required this.foto,
        required this.descripcion,
    });

    // Constructor factory fromJson: convierte un Map del JSON en un objeto Vehiculo.
    factory Vehiculo.fromJson(Map<String, dynamic> mapa) {
        return Vehiculo(
            // El campo 'id' del JSON se asigna directamente al atributo id.
            id:          mapa['id'],
            placa:       mapa['placa'],
            marca:       mapa['marca'],
            modelo:      mapa['modelo'],
            // precio llega como String desde MySQL. double.parse lo convierte a numero decimal.
            precio:      double.parse(mapa['precio']),
            estado:      mapa['estado'],
            foto:        mapa['foto'] ?? '',
            // ?? retorna '' si descripcion es null en la base de datos.
            descripcion: mapa['descripcion'] ?? '',
        );
    }
}
