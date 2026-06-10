import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/estacion.dart';
import 'auth_service.dart';

class ApiService {
  // Nota: 10.0.2.2 es el localhost para el emulador Android.
  // Si usa Linux Desktop, Web o dispositivo físico en la misma red, usa la IP de tu PC.
  static const String baseUrl = "http://127.0.0.1:8000";

  // 1. Obtener todas las estaciones
  Future<List<Estacion>> fetchEstaciones() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/estaciones/'))
          .timeout(const Duration(seconds: 5)); // Evita esperas infinitas

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Estacion.fromJson(data)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar con SMAT. ¿Está el servidor activo?');
    }
  }

  // 2. Crear una nueva estación
  Future<bool> crearEstacion(String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/estaciones/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({'nombre': nombre, 'ubicacion': ubicacion}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. Eliminar una estación
  Future<bool> eliminarEstacion(int id) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/estaciones/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Actualizar una estación existente
  Future<bool> editarEstacion(int id, String nombre, String ubicacion) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/estaciones/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': nombre,
          'ubicacion': ubicacion,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
} 
