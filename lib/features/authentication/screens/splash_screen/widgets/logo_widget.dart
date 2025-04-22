import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String imgPath;
  
  const LogoWidget({
    super.key, 
    required this.imgPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        imgPath,
        width: 120,
        height: 120,
      ),
    );
  }
}