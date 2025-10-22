import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:catalogo_pelis_flutter/movie_details_screen.dart';
import 'package:catalogo_pelis_flutter/background_widget.dart';

class PublicCatalogScreen extends StatelessWidget {
  const PublicCatalogScreen({super.key});

  // Widget Carrusel que consulta las películas y las muestra
  Widget _buildMovieCarousel(BuildContext context, String title, Query query) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 300, // Altura fija para el carrusel
          child: StreamBuilder<QuerySnapshot>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No hay películas en esta sección.', style: TextStyle(color: Colors.white)));
              }

              final movies = snapshot.data!.docs;

              return ListView.builder(
                scrollDirection: Axis.horizontal, 
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  var movieDoc = movies[index];
                  var movieData = movieDoc.data() as Map<String, dynamic>;
                  String title = movieData['title'] ?? 'Sin título';
                  String imageUrl = movieData['imageUrl'] ?? '';
                  String movieId = movieDoc.id; 

                  return SizedBox( 
                    width: 180, 
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: PublicMovieCard( // Usa el nuevo PublicMovieCard
                        title: title,
                        imageUrl: imageUrl,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MovieDetailsScreen(movieId: movieId),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definimos el color Azul Fuerte que usa el botón de invitado
    const Color strongBlue = Color(0xFF3b4cca);
    
    // Consultas
    Query latestMoviesQuery = FirebaseFirestore.instance.collection('movies')
        .orderBy('createdAt', descending: true).limit(6);
    Query generalQuery = FirebaseFirestore.instance.collection('movies')
        .orderBy('title', descending: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo Público (Solo Ver)'),
        backgroundColor: strongBlue, // <--- COLOR CORREGIDO: Azul Fuerte
      ),
      backgroundColor: Colors.transparent, 
      body: BackgroundWidget( 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMovieCarousel(context, 'Nuevo en MovieZone', latestMoviesQuery),
              _buildMovieCarousel(context, 'Catálogo General (A-Z)', generalQuery),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Tarjeta de Película Pública (SIN BOTONES DE EDITAR/ELIMINAR)
class PublicMovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const PublicMovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        color: Colors.white.withOpacity(0.9), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                          },
                        )
                      : const Center(child: Icon(Icons.movie, size: 50, color: Colors.grey)),
                  // NO HAY BOTONES DE ADMINISTRACIÓN AQUÍ
                ],
              ),
            ),
            // Título
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}