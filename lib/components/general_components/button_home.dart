import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

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
      onTap: isDisabled ? null : onPressed, // ❌ Disable tap if no function
      child: Column(
        children: [
          Container(
            width: 61,
            height: 61,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade300 : Colors.white, // 🔹 Gray when disabled
              border: Border.all(
                color: isDisabled ? Colors.grey.shade500 : const Color(0xFF14AE5C), // 🔹 Adjust border color
                width: 3,
              ),
              boxShadow: isDisabled
                  ? [] // ❌ Remove shadow when disabled
                  : [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0, // 🔹 Reduce opacity when disabled
                child: icon,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: MyText(
              text: text,
              fontSize: 14,
              color: isDisabled ? Colors.grey : Colors.black, // 🔹 Text color gray when disabled
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
