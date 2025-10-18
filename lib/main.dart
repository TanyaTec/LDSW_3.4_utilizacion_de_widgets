import 'package:flutter/material.dart';
// Importa la pantalla de login que debes crear en el archivo login_screen.dart
import 'package:catalogo_pelis_flutter/login_screen.dart'; 
// !!! NUEVA IMPORTACIÓN para la demo de API (Pokémon) !!!
import 'package:catalogo_pelis_flutter/poke_screen.dart'; 
// La importación de movie_catalog_screen.dart ya no es necesaria aquí.

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
      
      // *** REVERTIDO AL ESTADO ORIGINAL ***
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
        // 1. Fondo de Pantalla 
        Image.asset(
          'assets/images/cine.jpg', 
          fit: BoxFit.cover, // Para que la imagen cubra toda la pantalla
        ),
        // 2. Overlay Oscuro (para que el texto sea legible sobre la imagen)
        Container(
          color: Colors.black.withOpacity(0.5), // Capa semitransparente
        ),
        // 3. Contenido Centrado (Logo, Texto y Botones)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            // Column organiza los elementos verticalmente
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título de la Aplicación
                const Text(
                  'MovieZone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 52.0,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      // La sombra negra hace que el texto resalte
                      Shadow(
                        blurRadius: 8.0, // Suavidad de la sombra
                        color: Colors.black, // Color de la sombra
                        offset: Offset(3.0, 3.0), // Desplazamiento
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Imagen/Logo (Usamos un Icono como placeholder de Logo)
                const Icon(
                  Icons.local_movies,
                  color: Color(0xFFE50914), // Un color de cine
                  size: 150.0,
                ),
                const SizedBox(height: 40),
                // Mensaje de Bienvenida
                const Text(
                  '¡Bienvenid@ al mundo del cine!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22.0,
                  ),
                ),
                const SizedBox(height: 50),
                // Botón Ingresa (Navega a LoginScreen)
                ElevatedButton(
                  onPressed: () {
                    // Navega a la pantalla de Login/Registro al presionar
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914), // Fondo rojo de botón
                    padding: const EdgeInsets.symmetric(vertical: 15),
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
                const SizedBox(height: 15),
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
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xFFE50914), width: 2), // Borde rojo
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
                const SizedBox(height: 15), 
                // --- NUEVO BOTÓN PARA DEMO API ---
                OutlinedButton(
                  onPressed: () {
                    // Navega a la pantalla de demostración de la API
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PokeScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Color(0xFF3b4cca), width: 2), // Azul Pokémon
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Demo API (Pokémon)',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3b4cca)),
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