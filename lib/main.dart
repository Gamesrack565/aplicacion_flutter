import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_colors.dart';
import 'features/bitcafe/views/bitcafe_screen.dart';
import 'features/portfolio/views/portfolio_screen.dart';

// Punto de entrada principal de la aplicación.
void main() async {
  // Asegura la inicialización del motor de Flutter antes de configurar el sistema
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la orientación del dispositivo en modo horizontal
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const TabletPortfolioApp());
}

// Widget raíz que configura Material 3 y el tema global inicial.
class TabletPortfolioApp extends StatelessWidget {
  const TabletPortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portafolio Angel Higuera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.portfolioBlue),
      ),
      home: const TabletMasterScreen(),
    );
  }
}

// Contenedor maestro que alterna entre el Portafolio y el sistema BitCafe POS.
class TabletMasterScreen extends StatefulWidget {
  const TabletMasterScreen({super.key});

  @override
  State<TabletMasterScreen> createState() => _TabletMasterScreenState();
}

class _TabletMasterScreenState extends State<TabletMasterScreen> {
  // Estado de navegación superior: 0 = Portafolio | 1 = Sistema BitCafe
  int _modoActual = 0;

  @override
  Widget build(BuildContext context) {
    // Determina la paleta de colores activa según la pestaña seleccionada
    final bool esModoBitCafe = _modoActual == 1;
    final Color colorPrimarioActivo = esModoBitCafe ? AppColors.bitCafeRed : AppColors.portfolioBlue;
    final Color colorBarraSuperior = esModoBitCafe ? const Color(0xFF1E1E1E) : const Color(0xFF071120);

    // Inyecta dinámicamente el esquema de color al árbol de widgets hijo
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: colorPrimarioActivo),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior animada para cambiar de módulo en cualquier momento
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: colorBarraSuperior,
                child: Row(
                  children: [
                    Icon(
                      Icons.tablet_mac,
                      color: esModoBitCafe ? AppColors.bitCafeClock : AppColors.portfolioAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Angel Abraham Higuera Pineda',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Spacer(),
                    _buildTopSwitchButton(0, Icons.folder_special, '1. Portafolio', AppColors.portfolioBlue),
                    const SizedBox(width: 10),
                    _buildTopSwitchButton(1, Icons.coffee, '2. Sistema BitCafe (UI Completa)', AppColors.bitCafeRed),
                  ],
                ),
              ),
              // Renderiza la vista activa ocupando el resto de la pantalla
              Expanded(
                child: _modoActual == 0
                    ? HorizontalPortfolioView(onOpenBitCafe: () => setState(() => _modoActual = 1))
                    : const BitCafeSystemApp(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construye cada botón selector de la barra superior con estado activo/inactivo.
  Widget _buildTopSwitchButton(int index, IconData icon, String label, Color activeColor) {
    final activo = _modoActual == index;
    return InkWell(
      onTap: () => setState(() => _modoActual = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? activeColor : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activo ? Colors.white24 : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: activo ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}