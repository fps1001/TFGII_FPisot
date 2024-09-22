import 'package:flutter/material.dart';

import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/widgets/widgets.dart';

class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  _TourSelectionScreenState createState() => _TourSelectionScreenState();
}

class _TourSelectionScreenState extends State<TourSelectionScreen> {
  String selectedPlace = '';
  double numberOfSites = 2; // Valor inicial para el slider
  String selectedMode = 'walking'; // Modo de transporte por defecto es andando
  final List<bool> _isSelected = [true, false]; // Estado inicial del ToggleButton del medio de transporte

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Eco City Tour'), // Usa el CustomAppBar
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [

            //* SELECCIÓN DE LUGAR
            // Título de la pantalla
            Text(
              '¿Qué lugar quieres visitar?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

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
                  borderRadius:
                      BorderRadius.circular(25.0), // Bordes redondeados
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            //* SELECCIÓN DE NÚMERO DE SITIOS (SLIDER)
            const SizedBox(height: 30),
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

            //* SELECCIÓN DE MEDIO DE TRANSPORTE
            const SizedBox(height: 20),

            // Añadimos los ToggleButtons para seleccionar entre "andando" y "bici"
            Text(
              'Selecciona tu modo de transporte',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Center(
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(25.0),
                isSelected: _isSelected,
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _isSelected.length; i++) {
                      _isSelected[i] = i == index;
                    }
                    // Establece el modo de transporte según el índice
                    selectedMode = index == 0 ? 'walking' : 'cycling';
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.directions_walk),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.directions_bike),
                  ),
                ],
              ),
            ),

           //* BOTÓN DE PETICIÓN DE TOUR
            const SizedBox(height: 50),
            MaterialButton(
              minWidth: MediaQuery.of(context).size.width - 60,
              color: Theme.of(context).primaryColor,
              elevation: 0,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0), // Bordes redondeados
              ),
              onPressed: () async {
                                // Mostrar un mensaje de carga mientras obtenemos los POIs
                LoadingMessageHelper.showLoadingMessage(context);

                // Llama al servicio de Gemini para obtener los POIs
                final pois = await GeminiService.fetchGeminiData(
                  city: selectedPlace,
                  nPoi: numberOfSites.round(),
                );

                // Cierra el mensaje de carga
                Navigator.of(context).pop();

                // Verificar si se obtuvieron POIs
                if (pois.isEmpty) {
                  // Muestra un mensaje o maneja el caso en que no haya POIs
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se encontraron POIs')),
                  );
                  return;
                }

                // Navegar a la pantalla del mapa pasando los valores seleccionados
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      tour: EcoCityTour(
                        city: selectedPlace,
                        numberOfSites: numberOfSites.round(),
                        pois: pois,
                        mode: selectedMode,
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
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
