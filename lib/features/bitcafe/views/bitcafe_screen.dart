import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/bitcafe_models.dart';


//Notas para mi: Kanban es un metodo visual para gestionar el flujo de trabajo mediante tarjetas que avanzan a través de columnas según el estado de cada tarea

// Contenedor principal y gestor de estado del sistema BitCafe POS.
class BitCafeSystemApp extends StatefulWidget {
  const BitCafeSystemApp({super.key});

  @override
  State<BitCafeSystemApp> createState() => _BitCafeSystemAppState();
}

class _BitCafeSystemAppState extends State<BitCafeSystemApp> {
  bool _enPortada = true;
  String _vistaActual = 'Dashboard';

  // Catálogo inicial en memoria compartido entre vistas
  final List<ProductoBitCafe> _catalogo = [
    ProductoBitCafe(id: 1, nombre: 'Café Americano', categoria: 'Bebidas Calientes', precio: 35.0, activo: true),
    ProductoBitCafe(id: 2, nombre: 'Cappuccino Clásico', categoria: 'Bebidas Calientes', precio: 48.0, activo: true),
    ProductoBitCafe(id: 3, nombre: 'Latte Vainilla', categoria: 'Bebidas Calientes', precio: 52.0, activo: true),
    ProductoBitCafe(id: 4, nombre: 'Frappé Mocha', categoria: 'Bebidas Frías', precio: 58.0, activo: true),
    ProductoBitCafe(id: 5, nombre: 'Baguette de Pavo', categoria: 'Alimentos', precio: 65.0, activo: true),
    ProductoBitCafe(id: 6, nombre: 'Chilaquiles ESCOM', categoria: 'Alimentos', precio: 70.0, activo: true),
    ProductoBitCafe(id: 7, nombre: 'Muffin de Chocolate', categoria: 'Repostería', precio: 32.0, activo: true),
  ];

  // Lista reactiva de pedidos para el Dashboard y el Kanban
  final List<PedidoBitCafe> _pedidos = [
    PedidoBitCafe(
      id: 101,
      folio: 'BC-0101',
      hora: '10:15 AM',
      items: ['2x Café Americano', '1x Baguette de Pavo'],
      total: 135.0,
      estado: 'nuevo',
    ),
    PedidoBitCafe(
      id: 102,
      folio: 'BC-0102',
      hora: '10:18 AM',
      items: ['1x Frappé Mocha', '1x Muffin de Chocolate'],
      total: 90.0,
      estado: 'preparacion',
      minutosRestantes: 8,
    ),
    PedidoBitCafe(
      id: 103,
      folio: 'BC-0103',
      hora: '10:05 AM',
      items: ['1x Chilaquiles ESCOM', '1x Cappuccino Clásico'],
      total: 118.0,
      estado: 'listo',
    ),
  ];

  // Avanza el estado de un pedido dentro del flujo Kanban.
  void _cambiarEstadoPedido(int idPedido, String accion) {
    setState(() {
      final pedido = _pedidos.firstWhere((p) => p.id == idPedido);
      if (accion == 'pasar_preparacion') {
        pedido.estado = 'preparacion';
      } else if (accion == 'marcar_listo') {
        pedido.estado = 'listo';
      } else if (accion == 'marcar_entregado') {
        pedido.estado = 'entregado';
      }
    });
  }

  // Registra una nueva venta desde el POS manual y la inserta al inicio.
  void _crearNuevoPedidoManual(List<String> itemsTexto, double total) {
    final nuevoId = 100 + _pedidos.length + 1;
    final ahora = TimeOfDay.now();
    final horaStr =
        '${ahora.hourOfPeriod == 0 ? 12 : ahora.hourOfPeriod}:${ahora.minute.toString().padLeft(2, '0')} ${ahora.period == DayPeriod.am ? 'AM' : 'PM'}';

    setState(() {
      _pedidos.insert(
        0,
        PedidoBitCafe(
          id: nuevoId,
          folio: 'BC-0$nuevoId',
          hora: horaStr,
          items: itemsTexto,
          total: total,
          estado: 'nuevo',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Muestra la portada de inicio antes de entrar al sistema principal
    if (_enPortada) {
      return VistaPortadaWidget(
        onEntrarSistema: () => setState(() => _enPortada = false),
      );
    }

    return VentanaBaseWidget(
      vistaActual: _vistaActual,
      onMenuSelected: (opcion) {
        if (opcion == 'Cerrar Sesión') {
          setState(() {
            _enPortada = true;
            _vistaActual = 'Dashboard';
          });
        } else {
          setState(() => _vistaActual = opcion);
        }
      },
      child: _construirVistaInterna(),
    );
  }

  // Enrutador interno según la opción seleccionada en el menú lateral.
  Widget _construirVistaInterna() {
    switch (_vistaActual) {
      case 'Dashboard':
        return VistaDashboardWidget(
          pedidos: _pedidos,
          onIrMenu: () => setState(() => _vistaActual = 'Menú'),
          onIrPedidos: () => setState(() => _vistaActual = 'Pedidos'),
        );
      case 'Pedido Manual':
        return VistaPedidoManualWidget(
          catalogo: _catalogo,
          onRegistrarPedido: _crearNuevoPedidoManual,
        );
      case 'Pedidos':
        return VistaPedidosKanbanWidget(
          pedidos: _pedidos,
          onAccionPedido: _cambiarEstadoPedido,
        );
      case 'Menú':
        return VistaMenuAdminWidget(
          catalogo: _catalogo,
          onUpdate: () => setState(() {}),
        );
      case 'Ajustes':
        return const VistaAjustesWidget();
      default:
        return const SizedBox();
    }
  }
}

// Pantalla de bienvenida con simulación de conexión al servidor.
class VistaPortadaWidget extends StatefulWidget {
  final VoidCallback onEntrarSistema;
  const VistaPortadaWidget({super.key, required this.onEntrarSistema});

  @override
  State<VistaPortadaWidget> createState() => _VistaPortadaWidgetState();
}

class _VistaPortadaWidgetState extends State<VistaPortadaWidget> {
  bool _conectado = false;
  String _textoEstado = 'Iniciando sistema...';

  @override
  void initState() {
    super.initState();
    // Simulacion de la verificación inicial de red (1 segundo)
    // ESto se tenia en la version de python creada
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _conectado = true;
          _textoEstado = 'Sistema conectado correctamente.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.bitCafeCream,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('☕', style: TextStyle(fontSize: 90)),
          const SizedBox(height: 10),
          const Text(
            'Bit Cafe',
            style: TextStyle(color: AppColors.bitCafeRed, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Bienvenido', style: TextStyle(color: AppColors.bitCafeRed, fontSize: 20)),
          const SizedBox(height: 28),
          Container(
            width: 300,
            height: 50,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.bitCafeRed.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: OutlinedButton(
              onPressed: _conectado ? widget.onEntrarSistema : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.bitCafeRed,
                disabledForegroundColor: const Color(0xFFFFCDD2),
                side: BorderSide(
                  color: _conectado ? AppColors.bitCafeRed : const Color(0xFFFFCDD2),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Entrar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _textoEstado,
            style: TextStyle(
              color: _conectado ? const Color(0xFF2E7D32) : const Color(0xFFE57373),
              fontSize: 13,
              fontStyle: _conectado ? FontStyle.normal : FontStyle.italic,
              fontWeight: _conectado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Plantilla base con barra lateral de navegación y reloj en tiempo real.
class VentanaBaseWidget extends StatefulWidget {
  final String vistaActual;
  final ValueChanged<String> onMenuSelected;
  final Widget child;

  const VentanaBaseWidget({
    super.key,
    required this.vistaActual,
    required this.onMenuSelected,
    required this.child,
  });

  @override
  State<VentanaBaseWidget> createState() => _VentanaBaseWidgetState();
}

class _VentanaBaseWidgetState extends State<VentanaBaseWidget> {
  late Timer _timer;
  String _textoReloj = '';

  final List<String> _opciones = [
    'Dashboard',
    'Pedido Manual',
    'Pedidos',
    'Menú',
    'Ajustes',
    'Cerrar Sesión',
  ];

  @override
  void initState() {
    super.initState();
    _actualizarReloj();
    // Actualiza el reloj cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarReloj());
  }

  @override
  void dispose() {
    _timer.cancel(); // Libera el Timer al destruir el widget
    super.dispose();
  }

  // Formatea la fecha y hora actual estilo punto de venta.
  void _actualizarReloj() {
    final ahora = DateTime.now();
    const dias = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    const meses = ['ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN', 'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'];
    final diaSem = dias[ahora.weekday - 1];
    final mes = meses[ahora.month - 1];
    final hora12 = ahora.hour % 12 == 0 ? 12 : ahora.hour % 12;
    final ampm = ahora.hour >= 12 ? 'PM' : 'AM';
    final min = ahora.minute.toString().padLeft(2, '0');

    setState(() {
      _textoReloj = '$diaSem ${ahora.day} $mes | ${hora12.toString().padLeft(2, '0')}:$min $ampm';
    });
  }

  @override
  Widget build(BuildContext context) {
    final tituloHeader = widget.vistaActual == 'Ajustes' ? 'Configuración del Sistema' : widget.vistaActual;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Sidebar lateral fijo (220px)
          Container(
            width: 220,
            color: AppColors.bitCafeRed,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Text('☕', style: TextStyle(fontSize: 40, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('BitCafe', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  _textoReloj,
                  style: const TextStyle(color: AppColors.bitCafeClock, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ..._opciones.map((opcion) {
                  final esSeleccionado = widget.vistaActual == opcion;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => widget.onMenuSelected(opcion),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                          color: esSeleccionado ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
                          child: Text(
                            opcion,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      if (opcion == 'Ajustes') const SizedBox(height: 40),
                    ],
                  );
                }),
              ],
            ),
          ),
          // Lienzo derecho para la vista activa
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(36, 22, 36, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6), width: 1)),
                    ),
                    child: Text(
                      tituloHeader,
                      style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Vista de métricas del día e historial reciente de pedidos.
class VistaDashboardWidget extends StatelessWidget {
  final List<PedidoBitCafe> pedidos;
  final VoidCallback onIrMenu;
  final VoidCallback onIrPedidos;

  const VistaDashboardWidget({
    super.key,
    required this.pedidos,
    required this.onIrMenu,
    required this.onIrPedidos,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo dinámico de indicadores (KPIs)
    final nuevosCount = pedidos.where((p) => p.estado == 'nuevo').length;
    final prepCount = pedidos.where((p) => p.estado == 'preparacion').length;
    final ventasTotal = pedidos.fold<double>(0, (sum, p) => sum + p.total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ultimos pedidos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final p = pedidos[index];
              return Container(
                height: 56,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFECECEC)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 65,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7DF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Nuevo', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 160,
                      child: Text('Folio ${p.folio}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF333333), fontSize: 13)),
                    ),
                    // Descripción con recorte automático (...) si excede el espacio
                    Expanded(
                      child: Text(
                        p.items.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 100,
                      child: Text(
                        '\$${p.total.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard('Pedidos Nuevos', '$nuevosCount'),
            const SizedBox(width: 36),
            _buildStatCard('Pedidos en preparación', '$prepCount'),
            const SizedBox(width: 36),
            _buildStatCard('Ventas del Día', '\$${ventasTotal.toStringAsFixed(0)}'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDashboardBtn('Añadir Producto', onIrMenu),
            const SizedBox(width: 40),
            _buildDashboardBtn('Ver Pedidos', onIrPedidos),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String titulo, String valor) {
    return Container(
      width: 200,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(titulo, style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111111))),
        ],
      ),
    );
  }

  Widget _buildDashboardBtn(String texto, VoidCallback onTap) {
    return SizedBox(
      width: 180,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bitCafeRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }
}

// Terminal de punto de venta (POS) con buscador autocompletable y carrito.
class VistaPedidoManualWidget extends StatefulWidget {
  final List<ProductoBitCafe> catalogo;
  final void Function(List<String> items, double total) onRegistrarPedido;

  const VistaPedidoManualWidget({
    super.key,
    required this.catalogo,
    required this.onRegistrarPedido,
  });

  @override
  State<VistaPedidoManualWidget> createState() => _VistaPedidoManualWidgetState();
}

class _VistaPedidoManualWidgetState extends State<VistaPedidoManualWidget> {
  // Carrito actual: {idProducto: cantidad}
  final Map<int, int> _ordenActual = {1: 1, 5: 1};

  // Calcula el monto total multiplicando precio unitario por cantidad.
  double get _totalPagar {
    double total = 0;
    _ordenActual.forEach((id, qty) {
      final prod = widget.catalogo.firstWhere((p) => p.id == id);
      total += prod.precio * qty;
    });
    return total;
  }

  // Empaqueta los artículos del carrito y los envía al tablero Kanban.
  void _procesarPago(String tipoAccion) {
    if (_ordenActual.isEmpty) return;
    final itemsTexto = _ordenActual.entries.map((e) {
      final prod = widget.catalogo.firstWhere((p) => p.id == e.key);
      return '${e.value}x ${prod.nombre}';
    }).toList();

    widget.onRegistrarPedido(itemsTexto, _totalPagar);
    setState(() => _ordenActual.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$tipoAccion exitoso: Pedido enviado al tablero Kanban.'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productosDisponibles = widget.catalogo.where((p) => p.activo).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda (65%): Buscador y desglose de la orden
        Expanded(
          flex: 65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Qué va a ordenar?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF111111))),
              const SizedBox(height: 8),
              Autocomplete<ProductoBitCafe>(
                displayStringForOption: (p) => p.nombre,
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) return productosDisponibles;
                  return productosDisponibles.where(
                        (p) => p.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                  );
                },
                onSelected: (prod) {
                  setState(() => _ordenActual[prod.id] = (_ordenActual[prod.id] ?? 0) + 1);
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Busca tu producto... (Toca para ver sugerencias)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: AppColors.bitCafeRed),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Text('Orden', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111111))),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: _ordenActual.entries.map((entry) {
                    final prod = widget.catalogo.firstWhere((p) => p.id == entry.key);
                    final qty = entry.value;
                    return Container(
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('☕', style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('${prod.categoria}   |   \$${prod.precio.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF666666), fontSize: 12)),
                              ],
                            ),
                          ),
                          _buildQtyBtn('−', () {
                            setState(() {
                              if (qty > 1) {
                                _ordenActual[prod.id] = qty - 1;
                              } else {
                                _ordenActual.remove(prod.id);
                              }
                            });
                          }),
                          SizedBox(width: 32, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                          _buildQtyBtn('+', () => setState(() => _ordenActual[prod.id] = qty + 1)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Columna derecha (35%): Botones de cobro y totalizador
        Expanded(
          flex: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              const Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => _procesarPago('Ticket impreso'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bitCafeRed, foregroundColor: Colors.white),
                  child: const Text('Imprimir Ticket', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 200,
                height: 45,
                child: OutlinedButton(
                  onPressed: () => _procesarPago('Pago registrado'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bitCafeRed,
                    side: const BorderSide(color: AppColors.bitCafeRed, width: 2),
                  ),
                  child: const Text('Pagar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              const Text('Total a Pagar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF555555))),
              const SizedBox(height: 6),
              Container(
                width: 200,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bitCafeRed, width: 2),
                ),
                child: Text(
                  '\$ ${_totalPagar.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.bitCafeRed),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQtyBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}

// Tablero Kanban de 3 columnas para seguimiento de pedidos en cocina.
class VistaPedidosKanbanWidget extends StatelessWidget {
  final List<PedidoBitCafe> pedidos;
  final void Function(int id, String accion) onAccionPedido;

  const VistaPedidosKanbanWidget({
    super.key,
    required this.pedidos,
    required this.onAccionPedido,
  });

  @override
  Widget build(BuildContext context) {
    final nuevos = pedidos.where((p) => p.estado == 'nuevo').toList();
    final prep = pedidos.where((p) => p.estado == 'preparacion').toList();
    final listos = pedidos.where((p) => p.estado == 'listo').toList();

    return Row(
      children: [
        Expanded(child: _buildKanbanColumn('Nuevos', const Color(0xFFC9FFB5), Colors.black, null, nuevos)),
        const SizedBox(width: 20),
        Expanded(
          child: _buildKanbanColumn(
            'En preparación',
            Colors.white,
            AppColors.bitCafeRed,
            Border.all(color: AppColors.bitCafeRed, width: 2),
            prep,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: _buildKanbanColumn('Listos', AppColors.bitCafeRed, Colors.white, null, listos)),
      ],
    );
  }

  Widget _buildKanbanColumn(
      String titulo,
      Color headerBg,
      Color headerTextColor,
      Border? headerBorder,
      List<PedidoBitCafe> lista,
      ) {
    return Column(
      children: [
        Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: headerBg, borderRadius: BorderRadius.circular(12), border: headerBorder),
          child: Text(titulo, style: TextStyle(color: headerTextColor, fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: lista.length,
            itemBuilder: (context, index) => _buildTarjetaKanban(lista[index]),
          ),
        ),
      ],
    );
  }

  // Tarjeta individual de pedido con botón de cambio de estado.
  Widget _buildTarjetaKanban(PedidoBitCafe p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.estado == 'nuevo' ? const Color(0xFFE8FBEA) : const Color(0xFFFFF8F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hora de Pedido: ${p.hora}', style: const TextStyle(color: AppColors.bitCafeRed, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 6),
          Text('Folio: ${p.folio}', style: const TextStyle(color: Color(0xFF555555), fontSize: 12)),
          const SizedBox(height: 6),
          Text(p.items.join('\n'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${p.total.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.bitCafeRed, fontWeight: FontWeight.w800, fontSize: 15)),
              if (p.estado == 'nuevo')
                ElevatedButton(
                  onPressed: () => onAccionPedido(p.id, 'pasar_preparacion'),
                  child: const Text('Cocinar →', style: TextStyle(fontSize: 11)),
                ),
              if (p.estado == 'preparacion')
                OutlinedButton(
                  onPressed: () => onAccionPedido(p.id, 'marcar_listo'),
                  child: const Text('Listo', style: TextStyle(fontSize: 11)),
                ),
              if (p.estado == 'listo')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.bitCafeRed, foregroundColor: Colors.white),
                  onPressed: () => onAccionPedido(p.id, 'marcar_entregado'),
                  child: const Text('Entregado', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Administración del catálogo con búsqueda en vivo y control de disponibilidad.
class VistaMenuAdminWidget extends StatefulWidget {
  final List<ProductoBitCafe> catalogo;
  final VoidCallback onUpdate;

  const VistaMenuAdminWidget({super.key, required this.catalogo, required this.onUpdate});

  @override
  State<VistaMenuAdminWidget> createState() => _VistaMenuAdminWidgetState();
}

class _VistaMenuAdminWidgetState extends State<VistaMenuAdminWidget> {
  String _filtro = '';

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = widget.catalogo.where((p) => p.nombre.toLowerCase().contains(_filtro.toLowerCase())).toList();

    return Column(
      children: [
        TextField(
          onChanged: (val) => setState(() => _filtro = val),
          decoration: const InputDecoration(hintText: '🔍 Buscar producto por nombre...', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: listaFiltrada.length,
            itemBuilder: (context, index) {
              final prod = listaFiltrada[index];
              return ListTile(
                leading: const Text('☕', style: TextStyle(fontSize: 22)),
                title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${prod.categoria} • \$${prod.precio.toStringAsFixed(2)}'),
                trailing: Switch(
                  value: prod.activo,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.bitCafeRed,
                  onChanged: (val) {
                    setState(() => prod.activo = val);
                    widget.onUpdate();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Configuración rápida de apertura y cierre de pedidos en tienda.
class VistaAjustesWidget extends StatefulWidget {
  const VistaAjustesWidget({super.key});

  @override
  State<VistaAjustesWidget> createState() => _VistaAjustesWidgetState();
}

class _VistaAjustesWidgetState extends State<VistaAjustesWidget> {
  bool _aceptandoPedidos = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SwitchListTile(
        title: const Text('¿Aceptando Pedidos en Tienda?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        value: _aceptandoPedidos,
        activeThumbColor: Colors.white,
        activeTrackColor: AppColors.bitCafeRed,
        onChanged: (v) => setState(() => _aceptandoPedidos = v),
      ),
    );
  }
}