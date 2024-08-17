import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin:EdgeInsetsDirectional.only(top: 10),
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: Colors.white,
        width: double.infinity,
        height: 50,
        child: GestureDetector(
          onTap: () {
            print('Buscar');
          },
          child: Row(
            children: [
              const Icon(Icons.search),
              const SizedBox(width: 10),
              const Text('¿Qué lugar quieres visitar?'),
            ],
          ),
        ),
      ),
    );
  }
}