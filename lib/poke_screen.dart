import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

// 1. Modelo de Datos para un Pokémon
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final String type;

  Pokemon({required this.id, required this.name, required this.imageUrl, required this.type});

  // Constructor de fábrica para crear un Pokémon a partir de JSON de la PokeAPI
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? 'Desconocido';
    final int id = json['id'] ?? 0;
    
    // Obtener el tipo principal (ej. Grass, Fire, Water)
    // Se asume que la lista 'types' existe y tiene al menos un elemento.
    final String type = (json['types'] as List)
                        .first['type']['name']
                        .toUpperCase();

    // URL del sprite frontal del Pokémon
    final String imageUrl = json['sprites']['front_default'] ?? 
                            'https://placehold.co/150x150/AAAAAA/FFFFFF?text=No+Img';
    
    return Pokemon(
      id: id,
      name: name.toUpperCase(),
      imageUrl: imageUrl,
      type: type,
    );
  }
}

// 2. Función de Petición HTTP para obtener un Pokémon aleatorio
Future<Pokemon> fetchRandomPokemon() async {
  // Genera un ID aleatorio del 1 al 151 (la primera generación)
  final randomId = Random().nextInt(151) + 1;
  const baseUrl = 'https://pokeapi.co/api/v2/pokemon/';
  final url = baseUrl + randomId.toString();

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return Pokemon.fromJson(jsonResponse);
  } else {
    // Lanza una excepción en caso de fallo de la petición
    throw Exception('Fallo al cargar el Pokémon. Código: ${response.statusCode}');
  }
}

// 3. La Pantalla Demo (Widget Stateful para manejar la petición asíncrona)
class PokeScreen extends StatefulWidget {
  const PokeScreen({super.key});

  @override
  State<PokeScreen> createState() => _PokeScreenState();
}

class _PokeScreenState extends State<PokeScreen> {
  // Future para mantener el estado de la petición y su resultado
  late Future<Pokemon> futurePokemon;

  @override
  void initState() {
    super.initState();
    // Inicia la petición HTTP al inicializar la pantalla
    futurePokemon = fetchRandomPokemon(); 
  }

  // Mapeo simple de colores basado en el tipo de Pokémon
  Color _getTypeColor(String type) {
    switch (type) {
      case 'FIRE': return Colors.red.shade600;
      case 'WATER': return Colors.blue.shade600;
      case 'GRASS': return Colors.green.shade600;
      case 'ELECTRIC': return Colors.amber.shade600;
      case 'POISON': return Colors.purple.shade600;
      case 'NORMAL': return Colors.brown.shade300;
      case 'BUG': return Colors.lightGreen.shade400;
      case 'ROCK': return Colors.brown.shade700;
      case 'GROUND': return Colors.yellow.shade700;
      case 'FIGHTING': return Colors.orange.shade800;
      default: return Colors.grey.shade600; // Para tipos desconocidos/otros
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTTP API DEMO (PokeAPI)', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3b4cca), // Azul Pokémon
        iconTheme: const IconThemeData(color: Colors.white), // Ícono de retroceso blanco
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          // FutureBuilder maneja los estados asíncronos (cargando, error, datos)
          child: FutureBuilder<Pokemon>(
            future: futurePokemon,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Estado 1: Cargando
                return const CircularProgressIndicator(color: Color(0xFFffde00));
              } else if (snapshot.hasError) {
                // Estado 2: Error
                return Text(
                  'Error de Conexión: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                );
              } else if (snapshot.hasData) {
                // Estado 3: Datos Recibidos (Muestra la tarjeta)
                final pokemon = snapshot.data!;
                return Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Nombre del Pokémon
                        Text(
                          pokemon.name,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3b4cca), 
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ID: #${pokemon.id}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Imagen (Sprite) del Pokémon
                        Image.network(
                          pokemon.imageUrl,
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 150, height: 150,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFFffde00))),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100, color: Colors.red),
                        ),
                        const SizedBox(height: 20),
                        // Tipo de Pokémon con color temático
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getTypeColor(pokemon.type),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tipo Principal: ${pokemon.type}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              // Mensaje por defecto si no hay datos (aunque la lógica de FutureBuilder cubre los casos)
              return const Text('Presiona el botón Demo API en la pantalla principal para iniciar.');
            },
          ),
        ),
      ),
    );
  }
}