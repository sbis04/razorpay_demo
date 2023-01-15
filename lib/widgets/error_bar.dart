import 'package:flutter/material.dart';

class ErrorBar extends StatelessWidget {
  const ErrorBar({
    Key? key,
    required bool isErrorBarVisible,
  })  : _isErrorBarVisible = isErrorBarVisible,
        super(key: key);

  final bool _isErrorBarVisible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isErrorBarVisible ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Text(
              'All fields are not valid',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
