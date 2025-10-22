import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AddMovieScreen extends StatefulWidget {
  // El constructor ya no necesita 'const' ya que es un StateFulWidget
  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _isLoading = false; // Estado de carga para la validación HTTP

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

  // FUNCIÓN PARA LA PETICIÓN HTTP: Valida si la URL de la imagen es accesible
  Future<bool> _validateImageUrl(String url) async {
    try {
      // Usamos http.head() para solo obtener las cabeceras (más rápido que GET)
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 5));
      // Si el código es 200 (OK) o 300-399 (Redirección), consideramos la URL válida
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      // Si hay un error de conexión, DNS, o timeout, la URL es inaccesible
      print('Error de validación HTTP: $e');
      return false;
    }
  }

  void _addMovie() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Activa el indicador de carga
      });

      final imageUrl = _imageUrlController.text;
      
      // 1. Ejecutar la validación HTTP
      final isValid = await _validateImageUrl(imageUrl);

      setState(() {
        _isLoading = false; // Desactiva el indicador de carga
      });

      if (!isValid) {
        // Muestra un error si la URL no es válida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: La URL de la imagen no es válida o es inaccesible.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Detiene la función si la URL es mala
      }

      // 2. Si es válida, guardar en Firestore
      try {
        await FirebaseFirestore.instance.collection('movies').add({
          'title': _titleController.text,
          'year': int.tryParse(_yearController.text),
          'director': _directorController.text,
          'genre': _genreController.text,
          'synopsis': _synopsisController.text,
          'imageUrl': imageUrl, 
          'createdAt': FieldValue.serverTimestamp(), // Marca de tiempo
        });

        // Muestra un mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Película guardada exitosamente en Firebase.'),
            backgroundColor: Color.fromARGB(255, 20, 100, 150),
          ),
        );
        
        // Regresa a la pantalla anterior
        Navigator.pop(context);
        
      } catch (e) {
        // Manejo de errores de Firebase
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar en Firebase: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget para construir los campos de texto
  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text, int maxLines = 1, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          // Icono si es el campo de imagen
          suffixIcon: labelText == 'URL de la Imagen' 
              ? IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () async {
                    final url = Uri.parse(controller.text);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url); // Abre la URL en el navegador
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se puede abrir la URL, verifica el formato.'), backgroundColor: Colors.orange)
                       );
                    }
                  },
                )
              : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
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
        title: const Text('Agregar Película al Catálogo'),
        backgroundColor: const Color(0xFFE50914),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_titleController, 'Título'),
                _buildTextField(_yearController, 'Año', keyboardType: TextInputType.number),
                _buildTextField(_directorController, 'Director'),
                _buildTextField(_genreController, 'Género'),
                _buildTextField(_synopsisController, 'Sinopsis', maxLines: 3),
                // Campo clave para la validación HTTP
                _buildTextField(_imageUrlController, 'URL de la Imagen'),
                
                const SizedBox(height: 30),
                
                // Muestra el indicador de carga o el botón
                _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                    : ElevatedButton(
                        onPressed: _addMovie,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Guardar Película', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}