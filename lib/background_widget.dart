import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  // El widget 'child' es el contenido de la pantalla (formulario, botones, catálogo)
  final Widget child; 
  
  const BackgroundWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Usamos el Container principal para aplicar la imagen como decoración
    return Container(
      // La clave para la calidad y la nitidez
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/cine.jpg'),
          fit: BoxFit.cover,
          // 1. Aplicamos un filtro de color oscuro directamente a la imagen.
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1), // Opacidad ajustada para ver la imagen
            BlendMode.darken,
          ),
          // 2. Usamos FilterQuality.medium para evitar que Chrome sobreprocese
          filterQuality: FilterQuality.medium, 
        ),
      ),
      // 3. El contenido de la pantalla se coloca sobre el fondo
      child: SafeArea(child: child),
    );
  }
}