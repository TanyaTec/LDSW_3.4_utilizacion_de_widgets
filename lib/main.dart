import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

// Importaciones de Pantallas
import 'package:catalogo_pelis_flutter/login_screen.dart';
import 'package:catalogo_pelis_flutter/poke_screen.dart'; 
import 'package:catalogo_pelis_flutter/movie_catalog_screen.dart'; 
import 'package:catalogo_pelis_flutter/public_catalog_screen.dart'; 
import 'package:catalogo_pelis_flutter/background_widget.dart'; 
import 'package:url_launcher/url_launcher.dart'; 

void main() async {
  // Inicialización de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieZone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter',
      ),
      home: const WelcomeScreen(), 
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BackgroundWidget(child: WelcomeBody()),
    );
  }
}

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({super.key});

  void _launchSocial(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
       await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Simulación: Abriendo enlace a $url'), backgroundColor: Colors.blueGrey),
      );
    }
  }

  void _navigateToLogin(BuildContext context, bool isLoginMode) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(initialLoginMode: isLoginMode)), 
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color strongBlue = Color(0xFF3b4cca);
    const Color primaryRed = Color(0xFFE50914);
    
    // --- LÓGICA DE ANCHO RESPONSIVO ---
    final screenWidth = MediaQuery.of(context).size.width;
    const breakpoint = 600.0;
    final isMobile = screenWidth < breakpoint;
    
    final double maxDesktopWidth = screenWidth * 0.33;
    final double restrictedWidth = maxDesktopWidth > 400 ? 400 : maxDesktopWidth;
    final double finalWidth = isMobile ? double.infinity : restrictedWidth;
    
    // Estilo unificado para los botones de autenticación (Rojo Sólido)
    final ButtonStyle authButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: primaryRed, 
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView( 
          child: Container(
            width: finalWidth, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título y Logo
                const Text(
                  'MovieZone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 52.0,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 8.0, color: Colors.black, offset: Offset(3.0, 3.0)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.local_movies,
                  color: primaryRed,
                  size: 150.0,
                ),
                const SizedBox(height: 40),
                const Text(
                  '¡Bienvenid@ al mundo del cine!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22.0,
                  ),
                ),
                const SizedBox(height: 50),
                
                // 1. Botón Catálogo Público (Para todos)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PublicCatalogScreen()), 
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: strongBlue, 
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Ver Catálogo (Invitado)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 30),

                // --- TEXTO EXPLICATIVO (MEJORA UX) ---
                const Text(
                  'Las siguientes opciones son solo para administradores del catálogo:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),
                // --- FIN TEXTO EXPLICATIVO ---

                // 2. Botón Ingresa (ADMIN - ROJO SÓLIDO)
                ElevatedButton(
                  onPressed: () => _navigateToLogin(context, true), 
                  style: authButtonStyle, 
                  child: const Text('Ingresa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), 
                ),
                const SizedBox(height: 15),
                
                // 3. Botón Regístrate (ADMIN - ROJO SÓLIDO)
                ElevatedButton(
                  onPressed: () => _navigateToLogin(context, false), 
                  style: authButtonStyle, 
                  child: const Text('Regístrate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)), 
                ),

                /* --- CÓDIGO OCULTO (DEMO API) --- */
                // const SizedBox(height: 15),
                // OutlinedButton(
                //   onPressed: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => const PokeScreen()));
                //   },
                //   style: OutlinedButton.styleFrom(
                //     padding: const EdgeInsets.symmetric(vertical: 15),
                //     side: BorderSide(color: strongBlue, width: 2),
                //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                //   ),
                //   child: Text('Demo API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: strongBlue)),
                // ),
                // /* --- FIN DEL CÓDIGO OCULTO (DEMO API) --- */
                
                // --- SECCIÓN DE REDES SOCIALES ---
                const SizedBox(height: 40), 
                const Text(
                  'Síguenos',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 10), 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.white, size: 28.0), 
                      onPressed: () => _launchSocial(context, 'https://www.facebook.com/moviezone'),
                    ),
                    const SizedBox(width: 10), 
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 28.0), 
                      onPressed: () => _launchSocial(context, 'https://x.com/moviezone'),
                    ),
                    const SizedBox(width: 10), 
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 28.0), 
                      onPressed: () => _launchSocial(context, 'https://www.instagram.com/moviezone'),
                    ),
                  ],
                ),
                
                // --- FOOTER SOLICITADO (ÚLTIMO ELEMENTO) ---
                const SizedBox(height: 30), 
                const Text(
                  'Desarrollo Web por TanyaTech',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54, // Color más tenue y discreto
                  ),
                ),
                // --- FIN FOOTER ---
              ],
            ),
          ),
        ),
      ),
    );
  }
}