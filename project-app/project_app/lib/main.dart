import 'package:flutter/material.dart';
import 'package:project_app/screens/screens.dart';

void main() => runApp(const ProjectApp());

class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EcoTour App',
        home: GpsAccessScreen()
    );
  }
}
