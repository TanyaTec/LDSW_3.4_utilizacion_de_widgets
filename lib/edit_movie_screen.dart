import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; 
import 'package:catalogo_pelis_flutter/background_widget.dart';

class EditMovieScreen extends StatefulWidget {
  final String movieId;
  const EditMovieScreen({super.key, required this.movieId});

  @override
  _EditMovieScreenState createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _imageUrlController = TextEditingController();

  late Future<DocumentSnapshot> _movieFuture;
  bool _isSaving = false; // Cambiado de _isLoading a _isSaving

  @override
  void initState() {
    super.initState();
    _movieFuture = _loadMovieData();
  }
  
  // Función para cargar los datos y pre-llenar los controladores
  Future<DocumentSnapshot> _loadMovieData() async {
    final doc = await FirebaseFirestore.instance.collection('movies').doc(widget.movieId).get();
    
    // Si el documento existe, pre-llenar los controladores aquí.
    if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Usamos addPostFrameCallback para evitar el error de "setState durante build"
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _titleController.text = data['title'] ?? '';
            // Aseguramos que el año sea string para el controlador
            _yearController.text = data['year']?.toString() ?? ''; 
            _directorController.text = data['director'] ?? '';
            _genreController.text = data['genre'] ?? '';
            _synopsisController.text = data['synopsis'] ?? '';
            _imageUrlController.text = data['imageUrl'] ?? '';
        });
    }
    return doc;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _directorController.dispose();
    _genreController.dispose();
    _synopsisController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Lógica de validación HTTP
  Future<bool> _validateImageUrl(String url) async {
    if (url.isEmpty) return true; // Permitir que la URL esté vacía si el desarrollador lo desea
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  void _updateMovie() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final imageUrl = _imageUrlController.text.trim();
      
      final isValid = await _validateImageUrl(imageUrl);

      if (!isValid) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: La URL de la imagen no es válida o inaccesible.'), backgroundColor: Colors.red),
        );
        return; 
      }

      // 1. CREAMOS EL MAPA DE DATOS A ENVIAR A FIRESTORE
      final updatedData = {
          'title': _titleController.text.trim(),
          // 2. CONVERTIMOS EL AÑO A INT ANTES DE ENVIARLO A FIRESTORE
          'year': int.tryParse(_yearController.text.trim()), 
          'director': _directorController.text.trim(),
          'genre': _genreController.text.trim(),
          'synopsis': _synopsisController.text.trim(),
          'imageUrl': imageUrl, 
          'updatedAt': FieldValue.serverTimestamp(), 
      };

      // 3. ACTUALIZAMOS EL DOCUMENTO USANDO EL ID DE LA PELÍCULA
      try {
        await FirebaseFirestore.instance.collection('movies').doc(widget.movieId).update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película actualizada con éxito.'), backgroundColor: Color.fromARGB(255, 20, 100, 150)),
        );
        Navigator.pop(context); // Regresa al catálogo
        
      } catch (e) {
        // 4. SI FALLA LA ACTUALIZACIÓN, MUESTRA EL ERROR REAL DE FIREBASE
        print('Firebase Update Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar en Firebase. Revisa consola.'), backgroundColor: Colors.red),
        );
      } finally {
         setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa ${labelText.toLowerCase()}';
          }
          if (labelText == 'Año' && value != null && int.tryParse(value) == null) {
            return 'Debe ser un número de año válido';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Película'),
        backgroundColor: const Color(0xFFE50914),
      ),
      body: BackgroundWidget(
        child: FutureBuilder<DocumentSnapshot>(
          future: _movieFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              // Manejo de errores de carga o documento no encontrado
              return Center(child: Text('Error al cargar la película.', style: const TextStyle(color: Colors.white)));
            }
            
            // Interfaz del formulario
            return Center(
              child: Card(
                margin: const EdgeInsets.all(20),
                color: Colors.white.withOpacity(0.9),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Modificar Datos de la Película', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        
                        _buildTextField(_titleController, 'Título'),
                        _buildTextField(_yearController, 'Año', keyboardType: TextInputType.number),
                        _buildTextField(_directorController, 'Director'),
                        _buildTextField(_genreController, 'Género'),
                        _buildTextField(_synopsisController, 'Sinopsis', maxLines: 3),
                        _buildTextField(_imageUrlController, 'URL de la Imagen'),
                        
                        const SizedBox(height: 30),
                        
                        _isSaving 
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                            : ElevatedButton(
                                onPressed: _updateMovie,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, 
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}