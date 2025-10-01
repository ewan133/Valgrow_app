import 'package:flutter/material.dart';

class MyHomeButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Widget icon;

  const MyHomeButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    bool isDisabled = onPressed == null;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // 60% white - main background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled 
                ? const Color(0xFFF6F6F6)
                : Colors.black.withOpacity(0.1), // 30% black with opacity for border
            width: 1,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04), // Subtle black shadow
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDisabled 
                    ? const Color(0xFFF6F6F6)
                    : const Color(0xFF14AE5C).withOpacity(0.1), // 10% green accent
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: isDisabled 
                      ? Colors.black.withOpacity(0.3)
                      : const Color(0xFF14AE5C), // 10% green accent for enabled icons
                  size: 22,
                ),
                child: icon,
              ),
            ),
            const SizedBox(height: 10),
            // Text with better overflow handling
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDisabled 
                        ? Colors.black.withOpacity(0.3) 
                        : Colors.black, // 30% black for text
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    height: 1.2, // Better line height
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
