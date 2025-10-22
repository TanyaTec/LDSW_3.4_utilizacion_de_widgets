import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:catalogo_pelis_flutter/add_movie_screen.dart';
import 'package:catalogo_pelis_flutter/movie_details_screen.dart';
import 'package:catalogo_pelis_flutter/background_widget.dart';
import 'package:catalogo_pelis_flutter/edit_movie_screen.dart';
import 'package:catalogo_pelis_flutter/movie_search_delegate.dart'; 

// CRÍTICO: Eliminamos 'const' de la clase principal
class MovieCatalogScreen extends StatelessWidget {
  // Eliminamos 'const' del constructor para que la clase no sea constante
  const MovieCatalogScreen({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _deleteMovie(BuildContext context, String movieId, String movieTitle) async {
    // Diálogo de confirmación antes de eliminar
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar "$movieTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('movies').doc(movieId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película eliminada con éxito.'), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
              final itemCount = movies.length;
              
              // Usamos ListView.builder simple con la física más estable para la web
              return NotificationListener<ScrollNotification>(
                // Captura el evento de scroll
                onNotification: (ScrollNotification notification) {
                  // Si el scroll es horizontal (el carrusel), lo CONSUMIMOS.
                  if (notification is ScrollUpdateNotification && 
                      notification.metrics.axis == Axis.horizontal) {
                    return true; 
                  }
                  return false; 
                },
                child: ListView.builder(
                  key: ValueKey(title), 
                  scrollDirection: Axis.horizontal, 
                  // Usamos ClampingScrollPhysics para una física estable y contenida
                  physics: const ClampingScrollPhysics(), 
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    var movieDoc = movies[index % movies.length]; 
                    var movieData = movieDoc.data() as Map<String, dynamic>;
                    String title = movieData['title'] ?? 'Sin título';
                    String imageUrl = movieData['imageUrl'] ?? '';
                    String movieId = movieDoc.id; 

                    return SizedBox( 
                      width: 180, 
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0), 
                        child: MovieCard(
                          title: title,
                          imageUrl: imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // CRÍTICO: ELIMINAMOS 'const' AQUÍ
                                builder: (context) => MovieDetailsScreen(movieId: movieId),
                              ),
                            );
                          },
                          onDelete: () => _deleteMovie(context, movieId, title),
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // CRÍTICO: ELIMINAMOS 'const' AQUÍ
                                builder: (context) => EditMovieScreen(movieId: movieId),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Consulta para "Nuevo en MovieZone" (Últimas 6)
    Query latestMoviesQuery = FirebaseFirestore.instance.collection('movies')
        .orderBy('createdAt', descending: true) // Ordenamos por fecha de creación (más recientes primero)
        .limit(6); // Limitamos a 6 películas

    // 2. Consulta para el Catálogo General
    Query generalQuery = FirebaseFirestore.instance.collection('movies')
        .orderBy('title', descending: false); // Ordenamos por título ascendente

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Películas'),
        backgroundColor: const Color(0xFFE50914),
        actions: [
          // BOTÓN DE BÚSQUEDA
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context, 
                delegate: MovieSearchDelegate(),
              );
            },
          ),
          
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'add_movie') {
                // CRÍTICO: ELIMINAMOS 'const' AQUÍ
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddMovieScreen()));
              } else if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'add_movie',
                child: Row(children: [Icon(Icons.add, color: Colors.black), SizedBox(width: 8), Text('Agregar Película (Alta)')]),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(children: [Icon(Icons.logout, color: Colors.black), SizedBox(width: 8), Text('Cerrar Sesión')]),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.transparent, 
      body: BackgroundWidget( 
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CARRUSEL 1: NUEVO EN MOVIEZONE ---
              _buildMovieCarousel(context, 'Nuevo en MovieZone', latestMoviesQuery),

              // --- CARRUSEL 2: Catálogo General ---
              _buildMovieCarousel(context, 'Catálogo General (A-Z)', generalQuery),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget Tarjeta de Película (Sin cambios)
class MovieCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  // CRÍTICO: Eliminamos 'const' del constructor, aunque MovieCard es StatelessWidget
  const MovieCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
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
                  
                  // Botones de Administración Apilados (Edición y Baja)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Column(
                      children: [
                        // 1. Botón de Edición
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          onPressed: onEdit, 
                        ),
                        // 2. Botón de BAJA (Eliminar)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
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