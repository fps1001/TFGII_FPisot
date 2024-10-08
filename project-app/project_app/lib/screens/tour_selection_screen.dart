// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar eventos
import 'package:project_app/helpers/helpers.dart'; // Importar el helper de iconos
import 'package:project_app/screens/screens.dart';
import '../blocs/blocs.dart';

class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  TourSelectionScreenState createState() => TourSelectionScreenState();
}

class TourSelectionScreenState extends State<TourSelectionScreen> {
  String selectedPlace = '';
  double numberOfSites = 2; // Valor inicial para el slider
  String selectedMode = 'walking'; // Modo de transporte por defecto es andando
  final List<bool> _isSelected = [
    true,
    false
  ]; // Estado del ToggleButton del transporte
  double maxTimeInMinutes = 90;

  // **Mapa para almacenar el estado de selección de preferencias**
  final Map<String, bool> selectedPreferences = {
    'Naturaleza': false,
    'Museos': false,
    'Gastronomía': false,
    'Deportes': false,
    'Compras': false,
    'Historia': false,
  };

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Eco City Tours',
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Cierra el teclado al hacer tap fuera.
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
              // SELECCIÓN DE LUGAR
              Text(
                '¿Qué lugar quieres visitar?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              //* Campo de texto para el lugar
              TextField(
                onChanged: (value) {
                  setState(() {
                    selectedPlace = value;
                  });
                  log.i(
                      'TourSelectionScreen: Lugar seleccionado: $selectedPlace');
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
              // Mostrar los extremos del slider en la misma línea
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('2', style: Theme.of(context).textTheme.headlineSmall),
                  Expanded(
                    // Hacer que el slider ocupe el espacio restante
                    child: Slider(
                      value: numberOfSites,
                      min: 2,
                      max: 8,
                      divisions: 6, // Cada paso representa un sitio
                      label: numberOfSites.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          numberOfSites = value;
                        });
                        log.i(
                            'TourSelectionScreen: Número de sitios seleccionado: ${numberOfSites.round()}');
                      },
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.8),
                    ),
                  ),
                  Text('8', style: Theme.of(context).textTheme.headlineSmall),
                ],
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
                    log.i(
                        'TourSelectionScreen: Modo de transporte seleccionado: $selectedMode');
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(transportIcons['walking']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(transportIcons['cycling']),
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
                    final bool isSelected = selectedPreferences[key] ?? false;

                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            preference?['icon'],
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
                              ? preference!['color']
                              : Colors.grey.shade400,
                        ),
                      ),
                      selectedColor: preference!['color'],
                      backgroundColor: isSelected
                          ? preference['color']
                          : preference['color']!.withOpacity(
                              0.1), // Más apagado si no está seleccionado
                      elevation: isSelected ? 4.0 : 1.0,
                      shadowColor: Colors.grey.shade300,
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedPreferences[key] =
                              selected; // Actualizamos el estado
                        });
                        log.i(
                            'TourSelectionScreen: Preferencia "$key" seleccionada: $selected');
                      },
                    );
                  }).toList(),
                ),
              ),

              //* SELECCIÓN DE TIEMPO MÁXIMO PARA LA RUTA (SLIDER)
              const SizedBox(height: 15),
              Text(
                'Tiempo máximo invertido en el trayecto:',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text('15m', style: Theme.of(context).textTheme.headlineSmall),
                  Expanded(
                    child: Slider(
                      value: maxTimeInMinutes,
                      min: 15,
                      max: 180, // Máximo 3 horas
                      divisions: 11, // Cada paso representa 15 minutos
                      label: formatTime(maxTimeInMinutes)
                          .toString(), // Mostrar horas y minutos formateados
                      onChanged: (double value) {
                        setState(() {
                          maxTimeInMinutes = value;
                        });
                        log.i(
                            'TourSelectionScreen: Tiempo máximo de ruta seleccionado: ${maxTimeInMinutes.round()} minutos');
                      },
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor:
                          Theme.of(context).primaryColor.withOpacity(0.8),
                    ),
                  ),
                  Text('3h', style: Theme.of(context).textTheme.headlineSmall),
                ],
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
                  // Para evitar copiar tanto texto voy a poner Salamanca por defecto.
                  if (selectedPlace.isEmpty) {
                    selectedPlace = 'Salamanca, España';
                    log.w(
                        'TourSelectionScreen: Lugar vacío, usando "Salamanca, España" por defecto.');
                  }

                  // Mostrar diálogo de carga
                  LoadingMessageHelper.showLoadingMessage(context);
                  log.i(
                      'TourSelectionScreen: Solicitando tour en $selectedPlace con $numberOfSites sitios.');

                  // Dispara el evento para cargar el tour
                  BlocProvider.of<TourBloc>(context).add(LoadTourEvent(
                      mode: selectedMode,
                      city: selectedPlace,
                      numberOfSites: numberOfSites.round(),
                      userPreferences: selectedPreferences.entries
                          .where((entry) => entry.value == true)
                          .map((entry) => entry.key)
                          .toList(),
                      maxTime: maxTimeInMinutes));

                  // Modificación en la pantalla de selección para cerrar el diálogo de carga
                  BlocProvider.of<TourBloc>(context).stream.listen((tourState) {
                    if (!tourState.isLoading &&
                        !tourState.hasError &&
                        tourState.ecoCityTour != null) {
                      if (mounted) {
                        // Verificamos si el widget aún está montado
                        Navigator.of(context)
                            .pop(); // Cerrar el diálogo de carga
                        log.i(
                            'TourSelectionScreen: Tour cargado exitosamente, navegando al mapa.');

                        // Navegar a la pantalla del mapa
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(tour: tourState.ecoCityTour!),
                          ),
                        );
                      }
                    } else if (tourState.hasError) {
                      if (mounted) {
                        Navigator.of(context)
                            .pop(); // Cerrar el diálogo de carga si hay un error
                        log.e('TourSelectionScreen: Error al cargar el tour.');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al cargar el tour'),
                          ),
                        );
                      }
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

  String formatTime(double minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins.round()}m'; // Solo mostrar minutos si es menos de una hora
    } else if (hours == 1 && mins == 0) {
      return '1 hora'; // Mostrar "1 hora" si es exactamente una hora
    } else if (hours == 1) {
      return '1 hora ${mins.round()}m'; // "1 hora" en singular con minutos
    } else if (mins == 0) {
      return '$hours horas'; // Mostrar solo horas si no hay minutos
    } else {
      return '$hours horas ${mins.round()}m'; // Mostrar horas y minutos
    }
  }
}
