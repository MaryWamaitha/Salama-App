import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  MenuItem({this.icon, this.label, this.page});
  final IconData icon;
  final String label;
  final String page;
  @override
  Widget build(BuildContext context) {
            return Column(
              children: [
                IconButton(
                   icon:Icon(
                    icon,
                    color: Colors.white70,
                    size: 30.0,
                  ),
                  onPressed:() {
                    Navigator.pushNamed(context,page);
                  } ,
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
