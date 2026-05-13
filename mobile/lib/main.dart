import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';
import 'services/auth_service.dart';

void main() => runApp(const SMATApp());

class SMATApp extends StatelessWidget {
  const SMATApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SMAT Mobile',
      // El home ahora depende de la verificación del token
      home: FutureBuilder<String?>(
        future: AuthService().getToken(),
        builder: (context, snapshot) {
          // Mientras verifica, muestra un indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Si el token existe, va al Home, si no, al Login
          if (snapshot.hasData && snapshot.data != null) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                // Volvemos a disparar el Future para traer datos frescos
                  futureEstaciones = ApiService().fetchEstaciones();
                });
              },
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) { ... },
              ),
            );
          }
          return const login_screen ();
        },
      ),
    );
  }
}

