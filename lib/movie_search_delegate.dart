import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:catalogo_pelis_flutter/movie_details_screen.dart';
import 'package:catalogo_pelis_flutter/public_catalog_screen.dart'; 

class MovieSearchDelegate extends SearchDelegate<String> {
  
  @override
  String get searchFieldLabel => 'Buscar por título...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE50914),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; 
          showSuggestions(context); 
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  // Muestra los resultados finales al presionar Enter o Submit
  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  // CRÍTICO: El cuerpo principal - Muestra sugerencias y resultados en tiempo real
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text("Escribe el título de una película para buscar."));
    }
    
    // Traemos TODAS las películas una vez y las filtramos en la App
    // Esto asegura que podemos hacer filtrado case-insensitive.
    return StreamBuilder<QuerySnapshot>(
      // Traemos la colección completa (o un gran lote), ordenado por título
      stream: FirebaseFirestore.instance
          .collection('movies')
          .orderBy('title') 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No hay datos disponibles.'));
        }

        // --- LÓGICA DE FILTRADO EN EL FRONTEND (CASE-INSENSITIVE) ---
        final lowercaseQuery = query.toLowerCase();
        
        final filteredResults = snapshot.data!.docs.where((doc) {
          final movieData = doc.data() as Map<String, dynamic>;
          // Convertimos el título guardado en Firebase a minúsculas para la comparación
          final title = movieData['title']?.toLowerCase() ?? '';
          
          // Buscamos si el título CONTIENE el texto buscado
          // Esto permite buscar "star" y encontrar "Star Wars" o "A Star Is Born"
          return title.contains(lowercaseQuery); 
        }).toList();
        // --- FIN DE LÓGICA DE FILTRADO ---


        if (filteredResults.isEmpty) {
          return Center(child: Text('No se encontraron resultados para "$query".'));
        }

        // Mostrar resultados en una cuadrícula
        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.65,
          ),
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            var movieDoc = filteredResults[index];
            var movieData = movieDoc.data() as Map<String, dynamic>;
            String title = movieData['title'] ?? 'Sin título';
            String imageUrl = movieData['imageUrl'] ?? '';
            String movieId = movieDoc.id; 

            return PublicMovieCard(
              title: title,
              imageUrl: imageUrl,
              onTap: () {
                close(context, title); // Cierra la búsqueda
                // Navega a los detalles
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movieId: movieId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}