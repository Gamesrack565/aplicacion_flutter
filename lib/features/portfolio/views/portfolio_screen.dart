import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../services/github_service.dart';

// Vista principal del portafolio exclusiva para vista horizontral
class HorizontalPortfolioView extends StatefulWidget {
  // Callback para cambiar a la pestaña del sistema BitCafe POS.
  final VoidCallback onOpenBitCafe;

  const HorizontalPortfolioView({super.key, required this.onOpenBitCafe});

  @override
  State<HorizontalPortfolioView> createState() => _HorizontalPortfolioViewState();
}

class _HorizontalPortfolioViewState extends State<HorizontalPortfolioView> {
  // Instancia del servicio HTTP para consultar la API de GitHub
  final GitHubService _gitHubService = GitHubService();

  // Enlaces de proyectos desplegados en producción (Vercel)
  final String urlVercel = 'https://ets-el-tesoro-del-saber-proyecto-we.vercel.app/';
  final String urlVercelClub = 'https://club-front-plataforma-test.vercel.app/';

  // Abre un enlace web en el navegador externo del dispositivo.
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Verifica que el widget siga montado antes de mostrar el aviso en pantalla
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abriendo enlace: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.portfolioBgDark,
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna Izquierda (55% del ancho): Tarjetas de proyectos del CV
          Expanded(
            flex: 55,
            child: ListView(
              children: [
                const Text(
                  'Proyectos Destacados en CV',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ProjectCard(
                  titulo: 'Plataforma Web de Evaluación Académica (El Tesoro del Saber)',
                  stack: 'Node.js • Python • FastAPI • JavaScript • RAG Gemini API',
                  descripcion:
                  'Arquitectura backend para +100 estudiantes activos, extracción de reseñas docentes y agente conversacional con RAG.',
                  accionWidget: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.portfolioBlue),
                    onPressed: () => _abrirUrl(urlVercel),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Abrir Plataforma Web en Vercel'),
                  ),
                ),
                ProjectCard(
                  titulo: 'Plataforma del Club de Ciberseguridad (ESCOM)',
                  stack: 'Frontend Web • Ciberseguridad • Git / GitHub • Vercel',
                  descripcion:
                  'Plataforma web oficial para la gestión de actividades, recursos técnicos y miembros del Club de Ciberseguridad de ESCOM.',
                  accionWidget: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.portfolioBlue),
                    onPressed: () => _abrirUrl(urlVercelClub),
                    icon: const Icon(Icons.security, size: 18),
                    label: const Text('Abrir Plataforma del Club en Vercel'),
                  ),
                ),
                ProjectCard(
                  titulo: 'BitCafe (Sistema de Gestión de Inventarios y POS)',
                  stack: 'Python • FastAPI • MySQL • Flutter / PyQt6 UI',
                  descripcion:
                  'Arquitectura backend y modelo relacional en MySQL con interfaz para terminales de punto de venta que reduce el tiempo de compra estudiantil.',
                  accionWidget: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1976D2)),
                    onPressed: widget.onOpenBitCafe,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Ejecutar Interfaz BitCafe'),
                  ),
                ),
                const ProjectCard(
                  titulo: 'Detector de SPAM SMS | App Móvil + Backend IA',
                  stack: 'Python • FastAPI • Kotlin • SVM (93% Accuracy) • Gemini API',
                  descripcion:
                  'Clasificador binario SVM entrenado con 3 datasets e integrado con Gemini API para resumir SMS maliciosos en tiempo real (Instalada en dispositivo).',
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Columna Derecha (45% del ancho): Consumo de API REST de GitHub en tiempo real
          Expanded(
            flex: 45,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.portfolioCardBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.portfolioAccent.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado del panel con botón para recargar la petición HTTP
                  Row(
                    children: [
                      const Icon(Icons.cloud_done, color: AppColors.portfolioAccent),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'API GitHub en Tiempo Real (Gamesrack565)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        onPressed: () => setState(() {}),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.portfolioAccent.withValues(alpha: 0.2)),
                  // Constructor asíncrono que escucha la respuesta de GitHubService
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: _gitHubService.obtenerRepositorios(),
                      builder: (context, snapshot) {
                        // Muestra indicador de carga mientras espera la respuesta HTTP
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.portfolioAccent),
                          );
                        }

                        // Obtiene los datos de la API o usa la lista de respaldo si hubo error
                        final repos = List<dynamic>.from(snapshot.data ?? GitHubService.reposRespaldo);

                        // Ordena los repositorios para mostrar primero los destacados en el CV
                        repos.sort((a, b) {
                          final aCV = GitHubService.reposDestacadosCV.contains(a['name']) ? 0 : 1;
                          final bCV = GitHubService.reposDestacadosCV.contains(b['name']) ? 0 : 1;
                          return aCV.compareTo(bCV);
                        });

                        return ListView.builder(
                          itemCount: repos.length,
                          itemBuilder: (context, i) {
                            final r = repos[i];
                            final esCV = GitHubService.reposDestacadosCV.contains(r['name']);
                            return Card(
                              color: esCV ? const Color(0xFF173156) : const Color(0xFF0E1D36),
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: esCV ? AppColors.portfolioAccent : Colors.transparent,
                                  width: 1.3,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  esCV ? Icons.star : Icons.code,
                                  color: esCV ? AppColors.portfolioAccent : Colors.white54,
                                ),
                                title: Text(
                                  r['name'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.5,
                                  ),
                                ),
                                subtitle: Text(
                                  r['description'] ?? 'Repositorio en GitHub',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_browser, color: AppColors.portfolioAccent),
                                  onPressed: () => _abrirUrl(r['html_url']),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget reutilizable sin estado para representar cada tarjeta de proyecto.
class ProjectCard extends StatelessWidget {
  final String titulo;
  final String stack;
  final String descripcion;
  final Widget? accionWidget; // Botón de acción opcional

  const ProjectCard({
    super.key,
    required this.titulo,
    required this.stack,
    required this.descripcion,
    this.accionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.portfolioCardBlue,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.portfolioAccent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(stack, style: const TextStyle(color: AppColors.portfolioAccent, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(descripcion, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          // Renderiza el botón inferior solo si fue proporcionado al crear la tarjeta
          if (accionWidget != null) ...[
            const SizedBox(height: 12),
            accionWidget!,
          ],
        ],
      ),
    );
  }
}