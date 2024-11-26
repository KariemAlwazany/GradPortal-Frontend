import 'package:flutter/material.dart';
class EditItemScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Item'),
      ),
      body: Center(
        child: Text('This is the Edit Item Screen'),
      ),
    );
  }
}