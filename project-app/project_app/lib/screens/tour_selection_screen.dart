import 'package:flutter/material.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'loading_screen.dart'; // Asegúrate de importar LoadingScreen

class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  _TourSelectionScreenState createState() => _TourSelectionScreenState();
}

class _TourSelectionScreenState extends State<TourSelectionScreen> {
  String selectedPlace = '';
  double numberOfSites = 2; // Valor inicial para el slider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Eco City Tour'), // Usa el CustomAppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título de la pantalla
            Text(
              '¿Qué lugar quieres visitar?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),

            // Campo de texto para el lugar sin sugerencias
            TextField(
              onChanged: (value) {
                setState(() {
                  selectedPlace = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Introduce un lugar', // Pista para el usuario
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0), // Bordes redondeados
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Pregunta del número de sitios
            Text(
              '¿Cuántos sitios te gustaría visitar?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),

            // Slider para seleccionar el número de sitios (2 a 8)
            Slider(
              value: numberOfSites,
              min: 2,
              max: 8,
              divisions: 6, // Cada paso representa un sitio
              label: numberOfSites.round().toString(),
              onChanged: (double value) {
                setState(() {
                  numberOfSites = value;
                });
              },
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).primaryColor.withOpacity(0.3),
            ),

            const SizedBox(height: 30),

            // Botón de realizar el tour
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width - 60,
              color: Theme.of(context).primaryColor,
              elevation: 0,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0), // Bordes redondeados
              ),
              onPressed: () async{
                // Llama al servicio del LLM con los valores seleccionados
                final pois = await GeminiService.fetchGeminiData(
                  city: selectedPlace,
                  nPoi: numberOfSites.round(),
                );

                // Verificar si se obtuvieron POIs
                if (pois.isEmpty) {
                  print('No points of interest found.');
                  return;
                }
                // Navegamos a la pantalla de carga
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoadingScreen()), // Cambio de pantalla
                );
              },
              child: Text(
                'REALIZAR ECO-CITY TOUR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
