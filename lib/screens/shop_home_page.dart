// ignore_for_file: use_full_hex_values_for_flutter_colors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/home_app_bar.dart';
import 'package:flutter_project/widgets/categories_widget.dart';
import 'package:flutter_project/widgets/items_widget.dart';

class HomePage extends StatelessWidget{

@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        HomeAppBar(),
        Container(
          //height: 500, //temporary
          padding: EdgeInsets.only(top: 15),
          decoration: BoxDecoration(
            color: Color(0xFFEDECF2),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
          child: Column(
            children: [
              //Search Widget
              Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 15),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Container(                  
                      margin: EdgeInsets.only(left: 5),
                      height: 50,
                      width: 298,
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.camera_alt,
                      size: 27,
                      color: Color(0xFF4C53A5),
                    )
                  ],
                ),
              ),

              //Categories
              Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(
                      vertical: 20, 
                      horizontal: 10
                      ),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA4C53A5),
                        ),
                        ),
              ),

                //CATEGORIES WIDGET
                CategoriesWidget(),

                //Items
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Text(
                    "Best Selling",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4C53A5),
                    ),
                  ),
                ),


                //Items Widget
                ItemsWidget(),
            ],
          ),
        ),
      ],),
      );
  }
}