import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demostración de Widgets',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Widgets Básicos de Flutter'),
        ),
        body: SingleChildScrollView( // Permite el scroll si el contenido es demasiado grande
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // --- Demostración de Text y Container ---
                const Text(
                  '1. Widget Text y Container',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.blue[100],
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: const Text(
                    'Este es un widget Text dentro de un widget Container. El Container nos permite añadir color, padding y margin.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),

                // --- Demostración de Row ---
                const Text(
                  '2. Widget Row',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      color: Colors.green[100],
                      padding: const EdgeInsets.all(8),
                      child: const Text('Elemento 1'),
                    ),
                    Container(
                      color: Colors.green[200],
                      padding: const EdgeInsets.all(8),
                      child: const Text('Elemento 2'),
                    ),
                    Container(
                      color: Colors.green[300],
                      padding: const EdgeInsets.all(8),
                      child: const Text('Elemento 3'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Demostración de Column ---
                const Text(
                  '3. Widget Column',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  color: Colors.yellow[100],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.yellow[200],
                        padding: const EdgeInsets.all(8),
                        child: const Text('Fila A'),
                      ),
                      Container(
                        color: Colors.yellow[300],
                        padding: const EdgeInsets.all(8),
                        child: const Text('Fila B'),
                      ),
                      Container(
                        color: Colors.yellow[400],
                        padding: const EdgeInsets.all(8),
                        child: const Text('Fila C'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // --- Demostración de Stack ---
                const Text(
                  '4. Widget Stack',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Widget de fondo (más grande)
                      Container(
                        width: 200,
                        height: 200,
                        color: Colors.red[200],
                      ),
                      // Widget en el medio
                      Positioned(
                        top: 40,
                        left: 40,
                        child: Container(
                          width: 120,
                          height: 120,
                          color: Colors.red[400],
                        ),
                      ),
                      // Widget en primer plano (más pequeño)
                      Positioned(
                        top: 80,
                        left: 80,
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.red[600],
                          child: const Center(
                            child: Text(
                              'Top',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}