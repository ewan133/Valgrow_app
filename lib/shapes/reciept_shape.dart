import 'package:flutter/material.dart';

class ReceiptBackground extends StatelessWidget {
  const ReceiptBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // page background
      body: Center(
        child: ClipPath(
          clipper: ReceiptClipper(),
          child: Container(
            width: 320, // fixed width for receipt look
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  "GCash Receipt",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "₱ 1,250.00",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Transaction Successful",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                SizedBox(height: 24),
                Text(
                  "Ref. No: 1234 5678 9012",
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 8),
                Text(
                  "Date: Aug 25, 2025 - 09:30 PM",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0); // start top-left
    path.lineTo(0, size.height - 20);

    double radius = 8;
    for (double x = 0; x < size.width; x += radius * 2) {
      path.arcToPoint(
        Offset(x + radius * 2, size.height - 20),
        radius: Radius.circular(radius),
        clockwise: false,
      );
    }

    path.lineTo(size.width, 0); // right side up
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
