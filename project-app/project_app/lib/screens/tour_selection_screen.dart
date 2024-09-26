import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/screens/screens.dart';

import 'package:project_app/widgets/widgets.dart';

import '../blocs/blocs.dart';

class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  _TourSelectionScreenState createState() => _TourSelectionScreenState();
}

class _TourSelectionScreenState extends State<TourSelectionScreen> {
  String selectedPlace = '';
  double numberOfSites = 2; // Valor inicial para el slider
  String selectedMode = 'walking'; // Modo de transporte por defecto es andando
  final List<bool> _isSelected = [
    true,
    false
  ]; // Estado inicial del ToggleButton del medio de transporte

  // Preferencias de usuario con iconos
  final Map<String, Map<String, dynamic>> userPreferences = {
    'Naturaleza': {
      'selected': false,
      'icon': Icons.park,
      'color': Colors.lightBlue
    },
    'Museos': {'selected': false, 'icon': Icons.museum, 'color': Colors.purple},
    'Gastronomía': {
      'selected': false,
      'icon': Icons.restaurant,
      'color': Colors.green
    },
    'Deportes': {
      'selected': false,
      'icon': Icons.sports_soccer,
      'color': Colors.red
    },
    'Compras': {
      'selected': false,
      'icon': Icons.shopping_bag,
      'color': Colors.teal
    },
    'Historia': {
      'selected': false,
      'icon': Icons.history_edu,
      'color': Colors.orange
    },
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Eco City Tour'), // Usa el CustomAppBar
      body: GestureDetector(
        onTap: () {
          //Cierra el teclado al hacer tap fuera.
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: bottomInset, // Ajuste automático para el teclado
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* SELECCIÓN DE LUGAR
              Text(
                '¿Qué lugar quieres visitar?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Campo de texto para el lugar
              TextField(
                onChanged: (value) {
                  setState(() {
                    selectedPlace = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Introduce un lugar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
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
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.8),
              ),

              //* SELECCIÓN DE MEDIO DE TRANSPORTE
              const SizedBox(height: 20),

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

              //* SELECCIÓN DE PREFERENCIAS DEL USUARIO (CHIPS)
              const SizedBox(height: 30),
              Text(
                '¿Cuáles son tus intereses?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),

              Center(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.center,
                  children: userPreferences.keys.map((String key) {
                    final preference = userPreferences[key];
                    final bool isSelected = preference!['selected'];

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            preference['icon'],
                            size: 20.0,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            key,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: BorderSide(
                          color: isSelected
                              ? preference['color']
                              : Colors.grey.shade400,
                        ),
                      ),
                      selectedColor: preference['color'],
                      backgroundColor: isSelected
                          ? preference['color']
                          : preference['color']!.withOpacity(0.3),
                      elevation: 4.0,
                      shadowColor: Colors.grey.shade300,
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          userPreferences[key]!['selected'] = selected;
                        });
                      },
                    );
                  }).toList(),
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
                  borderRadius: BorderRadius.circular(25.0),
                ),
                onPressed: () {
                  // Mostrar diálogo de carga
                  LoadingMessageHelper.showLoadingMessage(context);

                  // Dispara el evento para cargar el tour
                  BlocProvider.of<TourBloc>(context).add(LoadTourEvent(
                    mode: selectedMode,
                    city: selectedPlace,
                    numberOfSites: numberOfSites.round(),
                    userPreferences: userPreferences.entries
                        .where((entry) => entry.value['selected'] == true)
                        .map((entry) => entry.key)
                        .toList(),
                  ));

                  // Escucha los cambios en el estado del TourBloc
                  BlocProvider.of<TourBloc>(context).stream.listen((tourState) {
                    if (!tourState.isLoading &&
                        !tourState.hasError &&
                        tourState.ecoCityTour != null) {
                      // Navegar a la pantalla del mapa solo si el estado tiene un EcoCityTour cargado
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            tour: tourState.ecoCityTour!,
                          ),
                        ),
                      );
                    }
                  });
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
      ),
    );
  }
}
