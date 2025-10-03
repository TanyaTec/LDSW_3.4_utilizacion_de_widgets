import 'package:flutter/material.dart';

// Este es un widget simple sin estado (StatelessWidget)
// que sirve como un marcador de posición para la futura
// pantalla de inicio de sesión y registro.

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura básica de la aplicación.
    return const Scaffold(
      appBar: AppBar(
        title: Text('Ingreso y Registro'),
        backgroundColor: Color(0xFF1976D2), // Color de la barra superior
      ),
      body: Center(
        child: Text(
          'Aquí irá el formulario de Ingreso/Registro',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      ),
    );
  }
}