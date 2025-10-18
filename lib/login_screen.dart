import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro / Login'),
        backgroundColor: Colors.blueGrey,
      ),
      body: const Center(
        child: Text(
          '¡Esta es la pantalla de Login y Registro!',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      ),
    );
  }
}