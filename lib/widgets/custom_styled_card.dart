import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomStyledCard extends StatelessWidget {
  final String categoryName;
  final String imagePath;
  final String amountUsed;
  final Color cardColors;
  dynamic addExpenseOnTap;

   CustomStyledCard({
    super.key,
    required this.categoryName,
    required this.imagePath,
    required this.amountUsed,
    required this.cardColors,
    this.addExpenseOnTap,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final double baseWidth = 390; // Reference device width (e.g. iPhone 13)
    final double scale = screen.width / baseWidth;

    final double cardHeight = 380 * scale;
    final double cardWidth = 170 * scale;
    final double avatarRadius = 65 * scale;
    final double paddingLeft = 24 * scale;

    return ClipPath(
      clipper: CustomShapeClipper(),
      child: Container(
        height: cardHeight,
        width: cardWidth,
        color: cardColors,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * scale),
            Center(
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.white,
                child: Lottie.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
           Padding(
  padding: EdgeInsets.only(left: paddingLeft, right: paddingLeft, top: 16 * scale),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      
      SizedBox(height: 12 * scale),
      Text(
        categoryName,
        style: TextStyle(
          fontSize: 20 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      SizedBox(height: 16 * scale),
      Text(
        "Used",
        style: TextStyle(
          fontSize: 13 * scale,
          color: Colors.black87,
        ),
      ),
      Text(
        "₹$amountUsed",
        style: TextStyle(
          fontSize: 22 * scale,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      SizedBox(height: 26 * scale),
      Center(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black54, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed:addExpenseOnTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add Expense",
                style: TextStyle(
                  fontSize: 10 * scale,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle_outline,
                color: Colors.black,
                size: 12 * scale,
              ),
            ],
          ),
        ),
      ),
    ],
  ),
),

          ],
        ),
      ),
    );
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width / 2),
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomShapeClipper oldClipper) => false;
}
