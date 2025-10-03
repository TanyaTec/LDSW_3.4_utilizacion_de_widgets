import 'package:flutter/material.dart';
// Importa la pantalla de login que debes crear en el archivo login_screen.dart
import 'package:catalogo_pelis_flutter/login_screen.dart'; 

void main() {
  // Inicia la aplicación en el widget principal (MyApp)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Desactiva el banner de debug en la esquina
      debugShowCheckedModeBanner: false,
      title: 'MovieZone', // Nombre de la aplicación
      theme: ThemeData(
        // Define el color principal de la aplicación (un azul oscuro)
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Define la fuente principal de la app
        fontFamily: 'Inter', 
      ),
      // El punto de entrada inicial es la pantalla de bienvenida
      home: const WelcomeScreen(), 
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold proporciona la estructura base de la pantalla
    return const Scaffold(
      body: WelcomeBody(),
    );
  }
}

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Stack permite apilar widgets (el fondo y el contenido)
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // 1. Fondo de Pantalla (simulado con un degradado)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 12, 12, 12),
                Color.fromARGB(255, 30, 30, 30)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // 2. Contenido Centrado (Logo, Texto y Botones)
        Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            // Column organiza los elementos verticalmente
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título de la Aplicación
                Text(
                  'Bienvenid@ a MovieZone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Imagen/Logo (Usamos un Icono como placeholder de Logo)
                Icon(
                  Icons.local_movies,
                  color: Color(0xFFE50914), // Un color de cine
                  size: 100.0,
                ),
                SizedBox(height: 40),
                // Mensaje de Bienvenida
                Text(
                  '¡Hey bienvenid@ al mundo del cine!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 50),
                // Botón Ingresa
                ElevatedButton(
                  onPressed: () {
                    // Navega a la pantalla de Login/Registro al presionar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE50914), // Fondo rojo de botón
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Ingresa',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                SizedBox(height: 15),
                // Botón Regístrate (Usamos un botón Outline para diferenciar)
                OutlinedButton(
                  onPressed: () {
                    // Navega a la pantalla de Login/Registro al presionar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Color(0xFFE50914), width: 2), // Borde rojo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE50914)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}