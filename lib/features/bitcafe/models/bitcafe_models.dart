//============================================================================
// MODELOS DE DOMINIO - SIMULACION DEL SISTEMA BITCAFE REALIZADO EN PYTHON
//============================================================================
//En esta capa se definen las entidades de datos que comparten el Dashboard,
//el Punto de Venta (Pedido Manual), el Tablero Kanban y el Menú Admin.

//Representa un producto dentro del catálogo e inventario de BitCafe.

// *Dato curioso (Kotlin vs Dart):* En Kotlin declararías esto como un
// `data class ProductoBitCafe(val id: Int, var nombre: String, ...)`.
class ProductoBitCafe {
  // Identificador único e inmutable del producto.
  // En Dart, `final` equivale exactamente a `val` en Kotlin: solo se asigna
  // una vez en el constructor y no puede modificarse después.
  final int id;

  // Propiedades mutables del producto.
  // Al no llevar `final`, funcionan igual que declarar `var` en Kotlin,
  // permitiendo que el administrador edite el producto o apague el switch
  // de disponibilidad en tiempo real.
  String nombre;
  String categoria;
  double precio;
  bool activo;

  // Constructor con parámetros nombrados (`{}`) e inicialización directa (`this.`).
  ProductoBitCafe({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.precio,
    this.activo = true,
  });
}

// Representa una orden de compra activa dentro del flujo de trabajo
class PedidoBitCafe {
  // Datos fijos del ticket generados al momento del cobro (`final` = `val` en Kotlin).
  final int id;
  final String folio;
  final String hora;

  // Lista inmutable en referencia de los productos ordenados.
  // `List<String>` en Dart equivale a `List<String>` / `MutableList<String>` en Kotlin.
  final List<String> items;
  final double total;

  // Estado actual del pedido en el tablero Kanban:
  String estado;

  // Tiempo estimado de preparación en cocina (en minutos).
  final int minutosRestantes;

  // Constructor principal de la entidad Pedido.
  // Define 12 minutos por defecto si no se especifica otro tiempo al crear la orden.
  PedidoBitCafe({
    required this.id,
    required this.folio,
    required this.hora,
    required this.items,
    required this.total,
    required this.estado,
    this.minutosRestantes = 12,
  });
}