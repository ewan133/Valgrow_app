import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyHomeButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  final Widget icon;
  const MyHomeButton({super.key, required this.text, this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
              width: 61,
              height: 61,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF14AE5C), width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: icon
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: MyText(text: text, fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
            )
        ],
      ),
    );
  }
}