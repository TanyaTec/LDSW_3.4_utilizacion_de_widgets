import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMovieScreen extends StatefulWidget {
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
  final _imageUrlController = TextEditingController(); // Controlador para la URL de la imagen

  @override
  void dispose() {
    // Limpia los controladores cuando el widget se desecha
    _titleController.dispose();
    _yearController.dispose();
    _directorController.dispose();
    _genreController.dispose();
    _synopsisController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _addMovie() {
    // Valida el formulario antes de enviar
    if (_formKey.currentState!.validate()) {
      // Agrega la película a la colección 'movies' en Firestore
      FirebaseFirestore.instance.collection('movies').add({
        'title': _titleController.text,
        'year': int.tryParse(_yearController.text), // Convierte el año a número
        'director': _directorController.text,
        'genre': _genreController.text,
        'synopsis': _synopsisController.text,
        'imageUrl': _imageUrlController.text, // Guarda la URL de la imagen
      });
      // Regresa a la pantalla anterior
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Película al Catálogo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Usamos un SingleChildScrollView para evitar que el teclado tape los campos
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un año';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingresa un año válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _directorController,
                  decoration: InputDecoration(labelText: 'Director'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un director';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _genreController,
                  decoration: InputDecoration(labelText: 'Género'),
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un género';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _synopsisController,
                  decoration: InputDecoration(labelText: 'Sinopsis'),
                  maxLines: 3, // Permite escribir más texto para la sinopsis
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la sinopsis';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(labelText: 'URL de la Imagen'),
                   validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la URL de la imagen';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addMovie,
                  child: Text('Guardar Película'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}