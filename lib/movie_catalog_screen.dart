import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

// 1. Modelo de Datos para un Pokémon
class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  Pokemon({required this.id, required this.name, required this.imageUrl});

  // Constructor de fábrica para crear un Pokemon a partir de JSON
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final String name = json['name'] ?? 'Desconocido';
    final int id = json['id'] ?? 0;
    
    // La PokeAPI tiene un formato específico para las imágenes (sprites)
    final String imageUrl = json['sprites']['front_default'] ?? 
                            'https://placehold.co/150x150/AAAAAA/FFFFFF?text=No+Img';
    
    return Pokemon(
      id: id,
      name: name.toUpperCase(),
      imageUrl: imageUrl,
    );
  }
}

// 2. Función que realiza la Petición HTTP (PokeAPI)
Future<List<Pokemon>> fetchRandomPokemonList() async {
  List<Pokemon> pokemonList = [];
  
  // Vamos a obtener 10 Pokémon aleatorios para llenar la cuadrícula (el catálogo)
  for (int i = 0; i < 10; i++) {
    // Genera un ID aleatorio del 1 al 151 (Pokémon originales)
    final randomId = Random().nextInt(151) + 1;
    final url = 'https://pokeapi.co/api/v2/pokemon/$randomId';
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      pokemonList.add(Pokemon.fromJson(jsonResponse));
    } else {
      // Si un Pokémon falla, no rompemos la lista, solo mostramos el error en consola
      print('Fallo al cargar Pokémon $randomId: ${response.statusCode}');
    }
  }

  if (pokemonList.isEmpty) {
    throw Exception('Fallo al cargar cualquier Pokémon. Revisa tu conexión.');
  }
  
  return pokemonList;
}

// 3. La Pantalla que Muestra los Datos
class MovieCatalogScreen extends StatefulWidget {
  const MovieCatalogScreen({super.key});

  @override
  State<MovieCatalogScreen> createState() => _MovieCatalogScreenState();
}

class _MovieCatalogScreenState extends State<MovieCatalogScreen> {
  // Cambiamos el tipo de Future de Movie a Pokemon
  late Future<List<Pokemon>> futurePokemon;

  @override
  void initState() {
    super.initState();
    futurePokemon = fetchRandomPokemonList(); // Inicia la petición
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Cambiamos el título para reflejar la API que se está usando
        title: const Text('Catálogo de Pokémon (PokeAPI Demo)'),
        backgroundColor: const Color(0xFF3b4cca), // Azul de Pokémon
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: futurePokemon,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Indicador de carga
            return const Center(child: CircularProgressIndicator(color: Color(0xFFffde00))); // Amarillo de Pokémon
          } else if (snapshot.hasError) {
            // Muestra el error de conexión
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error de Petición HTTP: ${snapshot.error}', 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Muestra la cuadrícula de Pokémon
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 0.8, // Ajustado para los sprites de Pokémon
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pokemon = snapshot.data![index];
                return PokemonCard(pokemon: pokemon);
              },
            );
          }
          // Caso por defecto: no hay datos
          return const Center(child: Text('No se pudo cargar la lista de Pokémon.'));
        },
      ),
    );
  }
}

// Widget de Tarjeta de Pokémon
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  
  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen/Sprite del Pokémon
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                pokemon.imageUrl,
                fit: BoxFit.contain,
                scale: 1.0, // Aseguramos que el sprite se vea bien
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFffde00)));
                },
              ),
            ),
          ),
          // Nombre del Pokémon
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 8, right: 8),
            child: Text(
              '#${pokemon.id} - ${pokemon.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: Color(0xFF3b4cca),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
