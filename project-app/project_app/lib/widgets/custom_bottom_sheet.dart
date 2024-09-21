import 'package:flutter/material.dart';
import '../models/models.dart';

class CustomBottomSheet extends StatelessWidget {
  final PointOfInterest poi;

  const CustomBottomSheet({
    Key? key,
    required this.poi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poi.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (poi.description != null)
            Text(
              poi.description!,
              style: const TextStyle(fontSize: 14),
            ),
          const SizedBox(height: 10),
          if (poi.url != null)
            GestureDetector(
              onTap: () {
                // Manejar el comportamiento al tocar la URL
              },
              child: Text(
                poi.url!,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline),
              ),
            ),
          if (poi.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Image.network(
                poi.imageUrl!,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }
}
