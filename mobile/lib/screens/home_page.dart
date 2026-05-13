import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/estacion.dart';
import 'login_screen.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();

  void confirmarEliminacion(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar Estación?"),
        content: const Text("Esta acción borrará los datos permanentemente del servidor."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              bool ok = await apiService.eliminarEstacion(id);
              if (ok) {
                if (mounted) Navigator.pop(context);
                setState(() {}); // Refresca la lista
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Estación eliminada con éxito")),
                );
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void mostrarDialogoEdicion(BuildContext context, Estacion estacion) {
    final nombreCtrl = TextEditingController(text: estacion.nombre);
    final ubicacionCtrl = TextEditingController(text: estacion.ubicacion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Estación"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: ubicacionCtrl, decoration: const InputDecoration(labelText: "Ubicación")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              bool ok = await apiService.editarEstacion(estacion.id, nombreCtrl.text, ubicacionCtrl.text);
              if (ok) {
                if (mounted) Navigator.pop(context);
                setState(() {}); // Refresca la lista
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SMAT - Estaciones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: FutureBuilder<List<Estacion>>(
        future: apiService.fetchEstaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay estaciones registradas"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final estacion = snapshot.data![index];

              // --- PASO 3: Reto "Indicadores de Alerta Temprana" ---
              // Verde si < 50, Rojo si >= 50
              Color colorAlerta = estacion.valor < 50 ? Colors.green : Colors.red;

              return ListTile(
                // Aplicación del color según el valor del sensor
                leading: CircleAvatar(
                  backgroundColor: colorAlerta.withOpacity(0.2),
                  child: Icon(Icons.sensors, color: colorAlerta),
                ),
                title: Text(estacion.nombre),
                subtitle: Text("${estacion.ubicacion} - Valor: ${estacion.valor}"),
                
                // Paso 2: Botones de Editar y Eliminar
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => mostrarDialogoEdicion(context, estacion),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => confirmarEliminacion(context, estacion.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}