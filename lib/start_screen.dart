import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget{
  final Widget? child;
  const StartScreen({super.key, this.child});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>{

  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 3),() {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => widget.child!), (route) => false);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Welcome to \n',
              ),
              TextSpan(
                text: 'FEUP RIDES',
                style: TextStyle(
                  fontSize: 40, // Double the size of the rest of the text
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }





}