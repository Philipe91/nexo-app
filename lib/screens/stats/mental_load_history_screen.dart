import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/providers/mental_load_provider.dart';
import '../../core/providers/task_provider.dart';

class MentalLoadHistoryScreen extends StatefulWidget {
  const MentalLoadHistoryScreen({super.key});

  @override
  State<MentalLoadHistoryScreen> createState() => _MentalLoadHistoryScreenState();
}

class _MentalLoadHistoryScreenState extends State<MentalLoadHistoryScreen> {
  String _selectedRange = 'Semana'; // 'Semana' ou 'Mês'
  bool _isBarChart = true;

  // --- CORES DO TEMA "DARK DASHBOARD" ---
  final Color bgDark = const Color(0xFF1A1A2E); // Fundo Escuro Profundo
  final Color cardDark = const Color(0xFF16213E); // Card Azul Marinho
  final Color accentBlue = const Color(0xFF4E5AE8); // Azul Neon
  final Color accentCyan = const Color(0xFF0F3460); // Detalhes
  final Color textWhite = Colors.white;
  final Color textGrey = Colors.white54;

  @override
  void initState() {
    super.initState();
    // Salva o snapshot do dia ao abrir a tela (se ainda não existir)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = context.read<TaskProvider>();
      context.read<MentalLoadProvider>().saveDailySnapshot(taskProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<MentalLoadProvider>();
    
    // Filtra dados com base na seleção
    List<DailyLoadData> chartData = _processData(historyProvider.history, _selectedRange);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text("Dashboard Mental", style: GoogleFonts.outfit(color: textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: cardDark.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgDark, const Color(0xFF0F0C29)], // Degradê Escuro (Navy -> Midnight)
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER DE CONTROLES ---
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedRange == 'Semana' ? "Últimos 7 Dias" : "Últimos 30 Dias",
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textWhite),
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(DateTime.now()).toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: textGrey, letterSpacing: 1.5),
                    ),
                  ],
                ),
                
                // CONTROLES EM CÁPSULA
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      // Toggle Barra/Linha
                      _buildIconButton(_isBarChart ? Icons.bar_chart_rounded : Icons.show_chart_rounded, () {
                         setState(() => _isBarChart = !_isBarChart);
                      }),
                      Container(width: 1, height: 20, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 4)),
                      // Toggle Semana/Mês
                      GestureDetector(
                        onTap: () => setState(() => _selectedRange = (_selectedRange == 'Semana' ? 'Mês' : 'Semana')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _selectedRange,
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // --- GRÁFICO ---
            Container(
              height: 320,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                ],
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
                child: Column(
                  children: [
                     // Título do Gráfico
                     Row(
                       children: [
                         Icon(Icons.monitor_heart_outlined, color: accentBlue, size: 20),
                         const SizedBox(width: 8),
                         Text("Evolução da Carga", style: GoogleFonts.outfit(color: textGrey, fontSize: 14)),
                       ],
                     ),
                     const SizedBox(height: 24),

                    Expanded(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _isBarChart 
                            ? BarChartPainter(data: chartData, isDark: true)
                            : LineChartPainter(data: chartData, isDark: true),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Legenda (Eixo X)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _buildXAxisLabels(chartData),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // --- INSIGHTS ---
              Text(
                "ANÁLISE INTELIGENTE",
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Pico", 
                      "${_getPeakLoad(chartData)}%", 
                      Icons.bolt_rounded, 
                      Colors.amber
                    )
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      "Média", 
                      "${_getAverageLoad(chartData).toInt()}%", 
                      Icons.equalizer_rounded, 
                      Colors.cyanAccent
                    )
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildFullInsightCard(chartData),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          // Debug
          context.read<MentalLoadProvider>().generateMockHistory();
        },
        backgroundColor: cardDark,
        child: const Icon(Icons.refresh, color: Colors.white54),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
             child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: textWhite)),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildFullInsightCard(List<DailyLoadData> data) {
    if (data.isEmpty) return const SizedBox();
    DailyLoadData peak = data.reduce((curr, next) => curr.load > next.load ? curr : next);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [accentBlue, const Color(0xFF2E3A8C)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: accentBlue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
        ]
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dica do Nexo AI", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  "Seu pico foi ${peak.dayLabel}. Tente programar um descanso extra neste dia!",
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... Helpers de data ...
  int _getPeakLoad(List<DailyLoadData> data) {
     if (data.isEmpty) return 0;
     return data.map((e) => e.load).reduce(max);
  }

  double _getAverageLoad(List<DailyLoadData> data) {
     if (data.isEmpty) return 0;
     return data.map((e) => e.load).reduce((a, b) => a + b) / data.length;
  }

  List<Widget> _buildXAxisLabels(List<DailyLoadData> data) {
    if (data.isEmpty) return [];
    
    // Se for semana, mostra todos (ou abreviados)
    if (_selectedRange == 'Semana') {
       return data.map((d) => Text(
          d.dayLabel, 
          style: GoogleFonts.outfit(color: textGrey, fontWeight: FontWeight.w600, fontSize: 12)
        )).toList();
    } 
    
    // Se for mês, mostra a cada 5 dias
    List<Widget> labels = [];
    for (int i=0; i < data.length; i+=5) {
       labels.add(Text(
          data[i].dayLabel, 
          style: GoogleFonts.outfit(color: textGrey, fontWeight: FontWeight.w600, fontSize: 10)
        ));
    }
    return labels;
  }

  List<DailyLoadData> _processData(List<DailyLoad> history, String range) {
    // Mesmo helper de antes
    final daysToShow = range == 'Semana' ? 7 : 30;
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: daysToShow - 1)); // Inclui hoje
    
    Map<String, int> loadMap = {};
    for (var h in history) {
      loadMap[DateFormat('yyyy-MM-dd').format(h.date)] = h.load;
    }

    List<DailyLoadData> result = [];
    
    for (int i = 0; i < daysToShow; i++) {
      final date = cutoff.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final load = loadMap[dateKey] ?? 0; 
      
      String label = range == 'Semana' 
          ? DateFormat('E', 'pt_BR').format(date)
          : DateFormat('dd').format(date);

      result.add(DailyLoadData(
        dayLabel: label,
        load: load,
        // Cores neon dinâmicas
        color: load > 75 ? const Color(0xFFFF0055) : (load > 40 ? const Color(0xFFFFBE0B) : const Color(0xFF00F5D4)),
      ));
    }

    return result;
  }
}

class DailyLoadData {
  final String dayLabel;
  final int load;
  final Color color;

  DailyLoadData({required this.dayLabel, required this.load, required this.color});
}

// --- PAINTERS (Dark Mode Adjusted) ---

class BarChartPainter extends CustomPainter {
  final List<DailyLoadData> data;
  final bool isDark;
  BarChartPainter({required this.data, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()..style = PaintingStyle.fill;
    final double spacing = size.width / data.length;
    final double barWidth = spacing * 0.5; // Mais fino para look moderno

    // Grid Lines (opcional)
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.25), Offset(size.width, size.height * 0.25), gridPaint);

    for (int i = 0; i < data.length; i++) {
        final item = data[i];
        if (item.load == 0) continue; 

        final double barHeight = (item.load / 100) * size.height;
        
        // Gradiente Neon na barra
        paint.shader = LinearGradient(
          colors: [item.color, item.color.withOpacity(0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH((i * spacing), 0, barWidth, size.height));

        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            (i * spacing) + (spacing - barWidth) / 2, 
            size.height - barHeight,
            barWidth,
            barHeight,
          ),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        
        canvas.drawRRect(rect, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  final List<DailyLoadData> data;
  final bool isDark;
  LineChartPainter({required this.data, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double spacing = size.width / data.length;
    
    // Grid
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), gridPaint);

    for (int i = 0; i < data.length; i++) {
        final double x = (i * spacing) + (spacing / 2);
        final double y = size.height - ((data[i].load / 100) * size.height);
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX = ((i - 1) * spacing) + (spacing / 2);
          final prevY = size.height - ((data[i-1].load / 100) * size.height);
          final controlX = (prevX + x) / 2;
          path.cubicTo(controlX, prevY, controlX, y, x, y);
        }
    }
    
    // Gradiente da Linha (Multicolor)
    paint.shader = const LinearGradient(
      colors: [Color(0xFF00F5D4), Color(0xFF4E5AE8), Color(0xFFFF0055)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Glow Effect
    final shadowPaint = Paint()
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF4E5AE8).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    // canvas.drawPath(path, shadowPaint); // Opcional, se pesar performance remover

    // Fill Gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width - (spacing/2), size.height);
    fillPath.lineTo(spacing/2, size.height);
    fillPath.close();
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF4E5AE8).withOpacity(0.2), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
    
    // Dots
    for (int i = 0; i < data.length; i++) {
        final double x = (i * spacing) + (spacing / 2);
        final double y = size.height - ((data[i].load / 100) * size.height);
        
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(x, y), 6, Paint()..color = data[i].color.withOpacity(0.5));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
