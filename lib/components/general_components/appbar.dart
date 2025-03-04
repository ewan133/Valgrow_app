import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actionWidget;

  const MyAppbar({super.key, required this.title, this.actionWidget});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF14AE5C),
      toolbarHeight: 70, // Custom height
      title: MyText(
        text: title,
        fontSize: 30,
        color: Colors.black,
        fontWeight: FontWeight.w600,

      ),
      centerTitle: true,
      actions: [
        if (actionWidget != null) actionWidget!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70); // Define preferred size
}
