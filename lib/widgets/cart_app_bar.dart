import 'package:flutter/material.dart';
import 'package:flutter_project/screens/Shop/shop_home_page.dart';

class CartAppBar extends StatelessWidget{
  const CartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(25),
      child: Row(
        children: [
          InkWell(
            onTap: (){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShopHomePage(),
                ),
              );
            },
            child: 
            Icon(
              Icons.arrow_back,
               size: 30, 
               color: Color(0xFF3B4280,),
               ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              "Cart",
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B4280),
              ),
            ),
          ),
          Spacer(),
          Icon(
            Icons.more_vert,
            size: 30,
            color: Color(0xFF3B4280),
            )
        ],
      ),
    );
}
}