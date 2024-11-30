// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/cart_app_bar.dart';
import 'package:flutter_project/widgets/cart_bottom_bar.dart';
import 'package:flutter_project/widgets/cart_item_samples.dart';

class CartScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          CartAppBar(),
          Container(
            //height: 700,
            padding: EdgeInsets.only(top: 15),
            decoration: BoxDecoration(
              color: Color(0xFFEDECF2),
              borderRadius:BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
              ),
              child: Column(
                children: [
                  //CartItemSamples(),
                  Container(
                    decoration: 
                    BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF3B4280),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Add Coupon Code",
                            style: TextStyle(
                              color: Color(0xFF3B4280),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          )

                      ],
                    ),
                  )
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: CarBottomNavBar(), // im here continue
    );
}
}