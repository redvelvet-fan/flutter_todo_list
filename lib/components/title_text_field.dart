import 'package:flutter/material.dart';
import 'package:todo_list/utils/default_values.dart';

class TitleTextField extends StatelessWidget {
  final String? title;
  final String? hintText;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final double fontSize;
  final int? maxLines;

  const TitleTextField(
      {Key? key,
      this.title,
      this.hintText,
      this.fontSize = DefaultValues.fontSize,
      this.controller,
      this.onChanged,
      this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: DefaultValues.gap)
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 8,horizontal: 4),
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(fontSize: fontSize),
            border: const UnderlineInputBorder(),
          ),
        )
      ],
    );
  }
}
