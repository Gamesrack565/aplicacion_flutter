import 'dart:convert';
import 'package:http/http.dart' as http;

// Servicio encargado de consultar los repositorios públicos mediante la API REST de GitHub.
class GitHubService {
  // Usuario de GitHub a consultar.
  final String username;

  // Constructor con valor por defecto asignado a la cuenta del portafolio.
  GitHubService({this.username = 'Gamesrack565'});

  // Lista de repositorios prioritarios para posicionarlos al inicio con insignia destacada.
  static const List<String> reposDestacadosCV = [
    'club_front_plataforma',
    'Proyecto-PLN-Detector-de-SPAM-SMS-mexicano',
    'ETS-El-Tesoro-del-Saber---Proyecto_web',
    'BitCafe_proyectoADS',
  ];

  // Datos locales de respaldo (Fallback) en caso de pérdida de conexión o límite de peticiones.
  static final List<Map<String, dynamic>> reposRespaldo = [
    {
      'name': 'club_front_plataforma',
      'description': 'Plataforma web oficial del Club de Ciberseguridad de ESCOM desplegada en Vercel.',
      'html_url': 'https://github.com/Gamesrack565/club_front_plataforma',
    },
    {
      'name': 'Proyecto-PLN-Detector-de-SPAM-SMS-mexicano',
      'description': 'Clasificador binario de SMS Spam con SVM (93% accuracy), FastAPI, Kotlin y resúmenes con Gemini API.',
      'html_url': 'https://github.com/Gamesrack565/Proyecto-PLN-Detector-de-SPAM-SMS-mexicano',
    },
    {
      'name': 'ETS-El-Tesoro-del-Saber---Proyecto_web',
      'description': 'Plataforma web de evaluación académica en Node.js y FastAPI con agente conversacional RAG (Gemini).',
      'html_url': 'https://github.com/Gamesrack565/ETS-El-Tesoro-del-Saber---Proyecto_web',
    },
    {
      'name': 'BitCafe_proyectoADS',
      'description': 'Sistema de gestión de inventarios y punto de vEnta (POS) con arquitectura backend en FastAPI y MySQL.',
      'html_url': 'https://github.com/Gamesrack565/BitCafe_proyectoADS',
    },
  ];

  // Realiza una petición HTTP GET asíncrona para obtener los repositorios ordenados por fecha de actualización.
  Future<List<dynamic>> obtenerRepositorios() async {
    try {
      final url = Uri.parse('https://api.github.com/users/$username/repos?sort=updated');

      // Límite de 6 segundos para evitar bloqueos en la interfaz si la red es inestable
      final res = await http.get(url).timeout(const Duration(seconds: 6));

      // Si la respuesta es exitosa (HTTP 200 OK), decodifica el JSON de la API
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return reposRespaldo;
    } catch (_) {
      // Captura errores de red o DNS (SocketException / TimeoutException) y retorna el respaldo local
      return reposRespaldo;
    }
  }
}