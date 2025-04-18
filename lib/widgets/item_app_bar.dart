
// ignore_for_file: use_key_in_widget_constructors, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ItemAppBar extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context);
              },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Color(0xFF3B4280),
              ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Product",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 23,
                color: Color(0xFF3B4280),
              ),
            ),
          ),
          Spacer(),

        ],
      ),
    );
}
}