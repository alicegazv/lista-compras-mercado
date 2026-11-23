import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mascote original do app: uma sacolinha de compras fofa, desenhada em
/// código. Quando [animar] é verdadeiro, ela flutua, pisca e os brilhos
/// pulsam (efeito parecido com um GIF, sem arquivo de imagem).
class Mascote extends StatefulWidget {
  const Mascote({super.key, this.tamanho = 140, this.animar = true});

  final double tamanho;
  final bool animar;

  @override
  State<Mascote> createState() => _MascoteState();
}

class _MascoteState extends State<Mascote> with SingleTickerProviderStateMixin {
  late final AnimationController _controle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animar) _controle.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Mascote: sacolinha de compras sorrindo',
      image: true,
      child: AnimatedBuilder(
        animation: _controle,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controle.value);
          return Transform.translate(
            offset: Offset(0, -10 * t),
            child: CustomPaint(
              size: Size.square(widget.tamanho),
              painter: _PintorMascote(
                corSacola: cores.primary,
                corDetalhe: cores.onPrimary,
                piscar: widget.animar && _controle.value > 0.93,
                brilho: t,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PintorMascote extends CustomPainter {
  _PintorMascote({
    required this.corSacola,
    required this.corDetalhe,
    required this.piscar,
    required this.brilho,
  });

  final Color corSacola;
  final Color corDetalhe;
  final bool piscar;
  final double brilho;

  static const _corTraco = Color(0xFF3A2433);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Alça da sacola.
    final alca = Paint()
      ..color = corSacola
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.33, h * 0.12, w * 0.34, h * 0.34),
      math.pi,
      math.pi,
      false,
      alca,
    );

    // Corpo da sacola.
    final corpo = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.28, w * 0.64, h * 0.6),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(corpo, Paint()..color = corSacola);

    // Olhos (fechados quando pisca).
    final yOlho = h * 0.5;
    final olho = Paint()..color = _corTraco;
    final olhoFechado = Paint()
      ..color = _corTraco
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    final reflexo = Paint()..color = Colors.white;
    for (final x in [w * 0.38, w * 0.62]) {
      if (piscar) {
        canvas.drawLine(
          Offset(x - w * 0.035, yOlho),
          Offset(x + w * 0.035, yOlho),
          olhoFechado,
        );
      } else {
        canvas.drawCircle(Offset(x, yOlho), w * 0.045, olho);
        canvas.drawCircle(
          Offset(x + w * 0.015, yOlho - w * 0.017),
          w * 0.015,
          reflexo,
        );
      }
    }

    // Bochechas.
    final bochecha = Paint()..color = const Color(0xFFFFC1D9);
    for (final x in [w * 0.29, w * 0.71]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, h * 0.6),
          width: w * 0.11,
          height: h * 0.06,
        ),
        bochecha,
      );
    }

    // Sorriso.
    final boca = Paint()
      ..color = _corTraco
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.57),
        width: w * 0.12,
        height: h * 0.08,
      ),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      boca,
    );

    // Coraçãozinho na sacola.
    _coracao(canvas, Offset(w * 0.5, h * 0.76), w * 0.065, Paint()..color = corDetalhe);

    // Brilhos que pulsam.
    final corBrilho = Color.lerp(
      const Color(0x66FFC94D),
      const Color(0xFFFFC94D),
      brilho,
    )!;
    final estrela = Paint()..color = corBrilho;
    _estrela(canvas, Offset(w * 0.1, h * 0.26), w * 0.065 * (0.7 + 0.3 * brilho), estrela);
    _estrela(canvas, Offset(w * 0.9, h * 0.38), w * 0.05 * (1 - 0.3 * brilho), estrela);
    _estrela(canvas, Offset(w * 0.84, h * 0.12), w * 0.035, estrela);
  }

  void _coracao(Canvas canvas, Offset c, double r, Paint paint) {
    final caminho = Path()
      ..moveTo(c.dx, c.dy + r)
      ..cubicTo(c.dx - r * 1.6, c.dy - r * 0.2, c.dx - r * 0.6, c.dy - r * 1.4,
          c.dx, c.dy - r * 0.5)
      ..cubicTo(c.dx + r * 0.6, c.dy - r * 1.4, c.dx + r * 1.6, c.dy - r * 0.2,
          c.dx, c.dy + r)
      ..close();
    canvas.drawPath(caminho, paint);
  }

  void _estrela(Canvas canvas, Offset o, double r, Paint paint) {
    final caminho = Path()
      ..moveTo(o.dx, o.dy - r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
      ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
      ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
      ..close();
    canvas.drawPath(caminho, paint);
  }

  @override
  bool shouldRepaint(_PintorMascote antigo) =>
      antigo.piscar != piscar ||
      antigo.brilho != brilho ||
      antigo.corSacola != corSacola ||
      antigo.corDetalhe != corDetalhe;
}
