import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget{

  final TextEditingController? controller;
  final Key? fieldKey;
  final bool? isPassword;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;

  const FormContainerWidget({
    this.controller,
    this.fieldKey,
    this.isPassword,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,

  });

  @override
  _FormContainerWidgetState createState() => new _FormContainerWidgetState();

}

class _FormContainerWidgetState extends State<FormContainerWidget>{
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextFormField(
          style: TextStyle(
            color: Colors.blue,
          ),
          controller: widget.controller,
          keyboardType: widget.inputType,
          key: widget.fieldKey,
          obscureText: widget.isPassword == true ? _obscureText : false,
          onSaved: widget.onSaved,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          decoration: InputDecoration(
            labelText: widget.hintText,  // Use labelText for hint
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            suffixIcon: widget.isPassword == true
                ? GestureDetector(
              onTap: (){
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: _obscureText == false ? Colors.blue : Colors.grey,
              ),
            )
                : null,
          ),
        ),
      ),
    );
  }
}

