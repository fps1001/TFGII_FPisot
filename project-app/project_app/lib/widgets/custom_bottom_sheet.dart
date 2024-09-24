import 'package:flutter/material.dart';
import '../models/models.dart';

class CustomBottomSheet extends StatelessWidget {
  final PointOfInterest poi;

  const CustomBottomSheet({
    super.key,
    required this.poi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
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

        ],
      ),
    );
  }

 
}
