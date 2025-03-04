import 'package:flutter/material.dart';

class MyProfileDetails extends StatelessWidget {
  final String label;
  final String value;
  final void Function()? onTap;
  final bool? editable;

  const MyProfileDetails({
    super.key,
    this.editable,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (editable == true)
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blueAccent),
          onPressed: onTap,
        ),
      ],
    );
  }
}
