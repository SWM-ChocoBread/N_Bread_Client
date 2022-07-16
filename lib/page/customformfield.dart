import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    Key? key,
    required this.customHintText,
    this.customInputFormatters,
    this.customValidator,
  }) : super(key: key);
  final String customHintText;
  final List<TextInputFormatter>? customInputFormatters;
  final String? Function(String?)? customValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters:
          customInputFormatters, // prevents unwanted input types in the text field
      validator:
          customValidator, // function that validates input when instructed
      decoration: InputDecoration(
          hintText:
              customHintText), // provides hint text to be shown before any input
    );
  }
}
