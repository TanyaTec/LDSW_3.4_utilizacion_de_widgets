import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura base de la pantalla
    return Scaffold(
      appBar: AppBar(
        // Título de la pantalla de autenticación
        title: const Text('Pantalla de Autenticación', style: TextStyle(color: Colors.white)),
        // Color de fondo oscuro para la barra de navegación
        backgroundColor: const Color.fromARGB(255, 12, 12, 12),
        // Ícono de regreso blanco
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      // Fondo de pantalla oscuro
      backgroundColor: const Color.fromARGB(255, 12, 12, 12),
      body: const Center(
        child: Text(
          // Mensaje temporal para el placeholder
          'Aquí irá el formulario de Ingreso/Registro (Simple)',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}