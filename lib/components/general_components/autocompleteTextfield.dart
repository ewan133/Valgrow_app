import 'package:flutter/material.dart';

class MyAutoCompleteTextField extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> suggestions; // List of words for auto-suggest
  final TextEditingController controller;
  final Color color;
  final bool isReadOnly;
  final bool showRedAsterisk; // Show red asterisk for required fields

  const MyAutoCompleteTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.suggestions,
    required this.controller,
    required this.color,
    this.isReadOnly = false,
    this.showRedAsterisk = false, // Default to false
  });

  @override
  State<MyAutoCompleteTextField> createState() =>
      _MyAutoCompleteTextFieldState();
}

class _MyAutoCompleteTextFieldState extends State<MyAutoCompleteTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showRedAsterisk
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.suggestions.where((word) => word
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            widget.controller.text = selection;
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
            // Sync with the external controller
            textEditingController.text = widget.controller.text;

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              readOnly: widget.isReadOnly,
              onChanged: (val) => widget.controller.text = val,
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.color),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: widget.color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFBDBDBD),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment:
                  Alignment.topLeft, // ensures dropdown is aligned with field
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200, // scrollable if too many items
                    minWidth: 300, // match field width
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
