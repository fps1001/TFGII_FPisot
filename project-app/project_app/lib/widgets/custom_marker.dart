import 'package:flutter/material.dart';

class CustomMarker extends StatelessWidget {
  final String nombre;
  final String descripcion;

  const CustomMarker({
    super.key,
    required this.nombre,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
          isScrollControlled: true,
        );
      },
      child: CustomPaint(
        size: const Size(40, 60), // Define el tamaño del marcador
        painter: MarkerPainter(),
      ),
    );
  }
}

class MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw the marker background (drop shape)
    final Path path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width, size.height * 0.6)
      ..arcToPoint(
        Offset(0, size.height * 0.6),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Draw the inner circle
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.4),
      size.width / 4,
      circlePaint,
    );

    // Draw the inner icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\u{2693}', // Emoji for anchor
        style: TextStyle(
          fontSize: size.width / 3,
          color: Colors.blue,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height * 0.4 - textPainter.height / 2),
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
