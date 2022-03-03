import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  MenuItem({this.icon, this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 24.0,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
          ),
        )
      ],
    );
  }
}