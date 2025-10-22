import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:catalogo_pelis_flutter/background_widget.dart';
import 'package:url_launcher/url_launcher.dart'; // Importación necesaria para abrir enlaces

class MovieDetailsScreen extends StatelessWidget {
  final String movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  // Función para abrir la página de votación del usuario
  void _launchVotingUrl(String title) async {
    // Usamos IMDb para simular una página de votación fiable.
    // Buscamos la película por su título (aproximado) en IMDb.
    final url = Uri.parse('https://www.imdb.com/find/?q=${Uri.encodeComponent(title)}&s=tt');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Muestra un error si no puede abrir la URL (solo para prueba)
      print('Could not launch $url');
    }
  }

  // Widget auxiliar para formatear filas de detalles
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta del detalle
          SizedBox(
            width: 80, 
            child: Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white70),
            ),
          ),
          // Valor del detalle
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Película'),
        backgroundColor: const Color(0xFFE50914),
      ),
      // El Scaffold debe ser transparente para que se vea el fondo
      backgroundColor: Colors.transparent, 
      body: BackgroundWidget(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('movies').doc(movieId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Película no encontrada.', style: const TextStyle(color: Colors.white)));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'N/A';
            final year = data['year']?.toString() ?? 'N/A';
            final director = data['director'] ?? 'N/A';
            final genre = data['genre'] ?? 'N/A';
            final synopsis = data['synopsis'] ?? 'Sinopsis no disponible.';
            final imageUrl = data['imageUrl'] ?? '';
            
            // --- SIMULACIÓN DE RATING DE EXPERTOS ---
            const String expertRating = '8.2 / 10'; 
            // --- SIMULACIÓN DE RATING DE EXPERTOS ---

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // 1. IMAGEN DEL PÓSTER
                  Container( 
                    margin: const EdgeInsets.only(bottom: 20),
                    constraints: const BoxConstraints(maxHeight: 350, maxWidth: 250), 
                    alignment: MediaQuery.of(context).size.width < 600 ? Alignment.center : Alignment.topLeft, // Responsivo
                    child: ClipRRect( 
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.movie_filter, size: 100, color: Colors.white);
                                },
                              )
                            : const Icon(Icons.movie_filter, size: 100, color: Colors.white),
                    ),
                  ),
                  
                  // 2. Título
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE50914)),
                  ),
                  const SizedBox(height: 10),

                  // 3. RATING DE EXPERTOS Y BOTÓN DE VOTACIÓN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // RATING DE EXPERTOS (SIMULADO)
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        expertRating,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 30),
                      
                      // BOTÓN PARA VOTACIÓN DEL USUARIO (LINK EXTERNO)
                      ElevatedButton.icon(
                        onPressed: () => _launchVotingUrl(title),
                        icon: const Icon(Icons.rate_review, color: Colors.white, size: 18),
                        label: const Text('Votar en IMDb', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3c7490), // Un color de botón diferente
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(height: 30, color: Colors.white70),

                  // 4. Detalles Clave
                  _buildDetailRow(context, 'Director', director),
                  _buildDetailRow(context, 'Año', year),
                  _buildDetailRow(context, 'Género', genre),
                  
                  const Divider(height: 30, color: Colors.white70),

                  // 5. Sinopsis
                  const Text(
                    'Sinopsis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    synopsis,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}