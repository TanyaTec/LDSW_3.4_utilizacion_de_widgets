import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importa la pantalla para agregar películas que creamos
import 'package:catalogo_pelis_flutter/add_movie_screen.dart';
// Importa la pantalla para ver los detalles de la película
import 'package:catalogo_pelis_flutter/movie_details_screen.dart'; // Asegúrate de tener este archivo creado

class MovieCatalogScreen extends StatelessWidget {
  // --- CORRECCIÓN: AÑADIR ESTE CONSTRUCTOR CONSTANTE ---
  const MovieCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Agregamos la AppBar
      appBar: AppBar(
        title: const Text('Catálogo de Películas'),
        actions: [
          // 2. Agregamos un botón de menú (PopupMenuButton)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_movie') {
                // 3. Navegamos a la pantalla para agregar película
                Navigator.push(
                  context,
                  // El constructor de AddMovieScreen tampoco es const, así que quitamos 'const'
                  MaterialPageRoute(builder: (context) => AddMovieScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add_movie',
                child: Text('Agregar Película'),
              ),
              // Aquí puedes agregar más opciones de menú en el futuro
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 4. Obtenemos los datos de la colección 'movies' en tiempo real
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay películas en el catálogo.'));
          }

          // Si hay datos, construimos la lista
          final movies = snapshot.data!.docs;

          // 5. Usamos un GridView para mostrar las películas
          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Muestra 2 películas por fila
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7, // Ajusta la proporción de los elementos
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              var movie = movies[index].data() as Map<String, dynamic>;
              String title = movie['title'] ?? 'Sin título';
              String imageUrl = movie['imageUrl'] ?? ''; // URL de la imagen

              return GestureDetector(
                onTap: () {
                  // 6. Navega a la pantalla de detalles al tocar una película
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       // MovieDetailsScreen necesita un constructor 'const' si se va a usar aquí.
                       builder: (context) => MovieDetailsScreen(movieId: movies[index].id),
                     ),
                   );
                },
                child: Card(
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                // Manejo de errores si la imagen no carga
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.movie, size: 50);
                                },
                              )
                            : const Icon(Icons.movie, size: 50),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
