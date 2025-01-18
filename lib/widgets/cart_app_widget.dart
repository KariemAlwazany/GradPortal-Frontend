// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/cart_app_bar.dart';

class CartAppWidget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : ListView(
        children: [
          CartAppBar(onCartUpdated: () {  },),
        ],
      )
    );
}
}