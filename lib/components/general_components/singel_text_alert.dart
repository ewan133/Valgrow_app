import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MySingelTextAlert extends StatefulWidget {
  final TextEditingController editingController;
  final String hintText;
  final void Function()? onPressed;
  final String onpressedText;
  final int maxChar;

  const MySingelTextAlert({
    super.key,
    required this.editingController,
    required this.hintText,
    this.onPressed,
    required this.onpressedText, 
    required this.maxChar,
  });

  @override
  State<MySingelTextAlert> createState() => _MySingelTextAlertState();
}

class _MySingelTextAlertState extends State<MySingelTextAlert> {
  @override
  void initState() {
    super.initState();
    // Set the controller's text to the hintText if it is empty.
    if (widget.editingController.text.isEmpty) {
      widget.editingController.text = widget.hintText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: Colors.white,
      content: TextField(
        controller: widget.editingController,
        maxLength: widget.maxChar,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: widget.hintText, // still shows when the field is empty
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            widget.editingController.clear();
          },
          child: MyText(
            text: "Cancel",
            fontSize: 16,
            color: const Color.fromARGB(164, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (widget.onPressed != null) {
              widget.onPressed!();
            }
          },
          child: MyText(
            text: widget.onpressedText,
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
