import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget
{ 
const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => ForgetPasswordScreenState();
}

class ForgetPasswordScreenState extends State<ForgetPasswordScreen>{
  @override
  Widget build(BuildContext context) {
    return const Text('Forget Password');
}
}