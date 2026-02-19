import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MentalLoadHistoryScreen extends StatelessWidget {
  const MentalLoadHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dados Mockados para o Gráfico
    final List<DailyLoad> weeklyData = _generateMockData();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text("Histórico de Carga", style: GoogleFonts.fredoka(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sua Semana",
              style: GoogleFonts.fredoka(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF4E5AE8)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Acompanhe como foi a distribuição da carga mental nos últimos 7 dias.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            // --- GRÁFICO ---
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: BarChartPainter(data: weeklyData),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: weeklyData.map((d) => Text(
                      d.dayLabel, 
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)
                    )).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- INSIGHTS ---
            const Text(
              "Insights",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              icon: Icons.lightbulb_outline,
              color: Colors.amber,
              title: "Pico de Carga",
              description: "Quarta-feira foi o dia mais intenso. Tente delegar mais tarefas nesse dia!",
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              icon: Icons.favorite_border,
              color: Colors.pink,
              title: "Equilíbrio",
              description: "Você manteve uma média saudável de 45% de carga mental nesta semana.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({required IconData icon, required Color color, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DailyLoad> _generateMockData() {
    final days = ["Seg", "Ter", "Qua", "Qui", "Sex", "Sáb", "Dom"];
    final rng = Random();
    return List.generate(7, (index) {
      return DailyLoad(
        dayLabel: days[index],
        load: 20 + rng.nextInt(60), // Random 20-80
        color: index == 2 ? Colors.orange : const Color(0xFF4E5AE8), // Destaca Quarta
      );
    });
  }
}

class DailyLoad {
  final String dayLabel;
  final int load;
  final Color color;

  DailyLoad({required this.dayLabel, required this.load, required this.color});
}

class BarChartPainter extends CustomPainter {
  final List<DailyLoad> data;

  BarChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double barWidth = size.width / (data.length * 2);
    final double spacing = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double barHeight = (item.load / 100) * size.height;
      
      // Cor da Barra
      paint.color = item.color;

      // Desenha Barra (Arredondada no topo)
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          (i * spacing) + (spacing / 2) - (barWidth / 2),
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
