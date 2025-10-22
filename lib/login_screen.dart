import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:catalogo_pelis_flutter/movie_catalog_screen.dart'; 
import 'package:catalogo_pelis_flutter/background_widget.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

class LoginScreen extends StatefulWidget {
  final bool initialLoginMode; 

  const LoginScreen({super.key, this.initialLoginMode = true}); 

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; 
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _accessCodeController = TextEditingController(); 
  
  final _formKey = GlobalKey<FormState>();
  
  late bool _isLoginMode; 
  bool _isLoading = false;
  
  // CLAVE SECRETA DE ACCESO PARA ADMINISTRADORES
  static const String ADMIN_ACCESS_CODE = '1234'; 

  @override
  void initState() {
    super.initState();
    _isLoginMode = widget.initialLoginMode; 
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _accessCodeController.dispose(); 
    super.dispose();
  }

  void _navigateToCatalog() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MovieCatalogScreen()),
    );
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final accessCode = _accessCodeController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // Lógica de INICIO DE SESIÓN
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        _navigateToCatalog();
        
      } else {
        // Lógica de REGISTRO (CON VALIDACIÓN DE CÓDIGO SECRETO)
        
        // 1. Validar el Código de Acceso
        if (accessCode != ADMIN_ACCESS_CODE) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de acceso incorrecto.'), backgroundColor: Colors.red),
           );
           setState(() => _isLoading = false);
           return;
        }

        // 2. Crear el Usuario en Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        // 3. Guardar el estado de administrador en Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'isAdmin': true, // Marcar como administrador
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        _navigateToCatalog();
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error. Verifica tus credenciales.';
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil (mínimo 6 caracteres).';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo ya está registrado.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Credenciales incorrectas.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TÍTULOS CORREGIDOS SEGÚN UX
        title: Text(_isLoginMode ? 'Iniciar Sesión (Admin)' : 'Registro (Date de Alta como Administrador)'),
        backgroundColor: const Color(0xFFE50914),
        elevation: 0,
      ),
      body: BackgroundWidget(
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.9),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        _isLoginMode ? 'Bienvenido de Nuevo' : 'Verificación de Acceso',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // NUEVO CAMPO: Código de Acceso (Solo visible en modo Registro)
                    if (!_isLoginMode)
                      TextFormField(
                        controller: _accessCodeController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Código de Acceso Secreto',
                            // ELIMINADO: hintText: 'Ingresa 1234'
                        ),
                        validator: (value) {
                          if (!_isLoginMode && (value == null || value.isEmpty)) {
                            return 'El código de acceso es obligatorio.';
                          }
                          return null;
                        },
                      ),
                    if (!_isLoginMode)
                      const SizedBox(height: 15),

                    // Campo de Correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                      validator: (value) {
                        if (value == null || !value.contains('@')) {
                          return 'Por favor, ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    // Campo de Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Botón de Carga o Submit
                    if (_isLoading) 
                      const CircularProgressIndicator(color: Color(0xFFE50914))
                    else
                      ElevatedButton(
                        onPressed: _submitAuthForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE50914),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: Text(
                          _isLoginMode ? 'INICIAR SESIÓN' : 'REGISTRARME',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    
                    // Botón para cambiar de modo
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode; 
                          _formKey.currentState?.reset(); 
                        });
                      },
                      child: Text(
                        _isLoginMode
                            ? '¿No tienes cuenta? Regístrate'
                            : 'Ya tengo cuenta. Iniciar Sesión',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}