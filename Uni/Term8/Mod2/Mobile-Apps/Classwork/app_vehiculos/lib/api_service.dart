import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vehiculo.dart';
import 'reserva.dart';

class ApiService {

    // ============================================================
    // CONFIGURACION DE URL - Descomentar solo UNA opcion a la vez
    // ============================================================

    // OPCION 1: Flutter Web en Chrome + XAMPP puerto 80 (caso de esta clase)
    // Cuando Flutter corre en Chrome, la app y XAMPP estan en la misma
    // computadora. localhost funciona igual que en cualquier navegador.
    static const String _baseUrl =
        'http://localhost/vehiculos_api';

    // OPCION 2: Flutter Web en Chrome + XAMPP puerto 8080
    // Usar si XAMPP fue configurado en puerto 8080 por conflicto con el 80.
    // static const String _baseUrl =
    //     'http://localhost:8080/vehiculos_api';

    // OPCION 3: Emulador de Android + XAMPP puerto 80
    // 10.0.2.2 es la IP especial fija del emulador Android para apuntar
    // al localhost de la computadora donde corre XAMPP.
    // static const String _baseUrl =
    //     'http://10.0.2.2/vehiculos_api';

    // OPCION 4: Celular fisico + XAMPP (misma red WiFi)
    // Reemplazar 192.168.1.X con la IP local de la computadora.
    // Verla con 'ipconfig' en Windows o 'ifconfig' en Mac/Linux.
    // static const String _baseUrl =
    //     'http://192.168.1.X/vehiculos_api';

    // OPCION 5: Ngrok activo (cualquier dispositivo, desde cualquier red)
    // Reemplazar 'abc123' con la URL real que muestra Ngrok en ese momento.
    // Si Ngrok se reinicia la URL cambia: actualizar y hacer Hot Restart.
    // static const String _baseUrl =
    //     'https://abc123.ngrok-free.app/vehiculos_api';

    // ============================================================
    // CONFIGURACION DE HEADERS
    // ============================================================

    // Usar estos headers cuando la URL activa sea localhost (Opciones 1, 2 o 3).
    // Con localhost no hay pagina de aviso de Ngrok, el header extra es innecesario.
    static const Map<String, String> _headers = {};

    // Usar estos headers cuando la URL activa sea Ngrok (Opcion 4).
    // Sin el header ngrok-skip-browser-warning, Ngrok devuelve una pagina
    // HTML de aviso en lugar del JSON, y la app no puede parsear la respuesta.
    // static const Map<String, String> _headers = {
    //     'ngrok-skip-browser-warning': 'true',
    // };

    // ============================================================
    // METODOS DE LA API
    // ============================================================

    // Obtiene todos los vehiculos desde get_vehiculos.php
    Future<List<Vehiculo>> obtenerVehiculos() async {
        try {
            final response = await http.get(
                Uri.parse('$_baseUrl/get_vehiculos.php'),
                headers: _headers,
            );
            if (response.statusCode == 200) {
                final List datos = jsonDecode(response.body);
                return datos.map((d) => Vehiculo.fromJson(d)).toList();
            }
            throw Exception('Error del servidor: ${response.statusCode}');
        } catch (e) {
            rethrow;
        }
    }

    // Obtiene las reservas activas desde get_reservas.php
    Future<List<Reserva>> obtenerReservas() async {
        try {
            final response = await http.get(
                Uri.parse('$_baseUrl/get_reservas.php'),
                headers: _headers,
            );
            if (response.statusCode == 200) {
                final List datos = jsonDecode(response.body);
                return datos.map((d) => Reserva.fromJson(d)).toList();
            }
            throw Exception('Error del servidor: ${response.statusCode}');
        } catch (e) {
            rethrow;
        }
    }

    // Obtiene el detalle de un vehiculo por su ID desde get_vehiculo_detalle.php
    Future<Vehiculo> obtenerDetalle(int id) async {
        try {
            final response = await http.get(
                Uri.parse('$_baseUrl/get_vehiculo_detalle.php?id=$id'),
                headers: _headers,
            );
            if (response.statusCode == 200) {
                final Map<String, dynamic> dato =
                    jsonDecode(response.body);
                return Vehiculo.fromJson(dato);
            }
            throw Exception('Vehiculo no encontrado');
        } catch (e) {
            rethrow;
        }
    }
}
