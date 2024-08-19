import 'package:flutter/material.dart';
import 'package:project_app/delegates/delegates.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    // SafeArea para asegurar que no choca con parte de arriba.
    return SafeArea(
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        child: GestureDetector(
          onTap: () {
            showSearch(context: context, delegate: SearchDestinationDelegate());
          },
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 5))
                  ]),
              child: const Text(
                '¿Qué lugar quieres visitar?',
                style: TextStyle(color: Colors.black87),
              )),
        ),
      ),
    );
  }
}
