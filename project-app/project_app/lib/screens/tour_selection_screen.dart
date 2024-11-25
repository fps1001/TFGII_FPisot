import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/widgets/widgets.dart';

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
  int? selectedAssistant; // Puede ser nulo si no se selecciona asistente

  // **Mapa para almacenar el estado de selección de preferencias**
  final Map<String, bool> selectedPreferences = {
    'Naturaleza': false,
    'Museos': false,
    'Gastronomía': false,
    'Deportes': false,
    'Compras': false,
    'Historia': false,
  };

  void _onTagSelected(String key) {
    setState(() {
      selectedPreferences[key] = !selectedPreferences[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false, // Impide cualquier acción de retroceso
      child: Scaffold(
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
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.drive_file_move_rounded),
              tooltip: 'Cargar Ruta Guardada',
              onPressed: () async {
                final tourBloc = BlocProvider.of<TourBloc>(context);
                // Dispara el evento para cargar los tours guardados
                tourBloc.add(const LoadSavedToursEvent());

                // Esperar un momento para asegurarse de que la lista está cargada antes de navegar
                await Future.delayed(const Duration(milliseconds: 500));

                if (context.mounted) {
                  context.pushNamed('saved-tours');
                }
              },
            ),
          ],
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

                //* TEXT-BOX PARA EL LUGAR
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
                NumberOfSitesSlider(
                  numberOfSites: numberOfSites,
                  onChanged: (double value) {
                    setState(() {
                      numberOfSites = value;
                    });
                    log.i(
                        'TourSelectionScreen: Número de sitios seleccionado: ${numberOfSites.round()}');
                  },
                ),
                //* SELECCIÓN DE ASISTENTE DE IA
                const SizedBox(height: 20),
                SelectAIAssistant(
                  onAssistantSelected: (index) {
                    setState(() {
                      selectedAssistant = index; // Permite `null`
                    });
                    log.i(
                        'TourSelectionScreen: Asistente seleccionado: ${index ?? "Sin selección"}');
                  },
                ),

                //* SELECCIÓN DE MEDIO DE TRANSPORTE
                TransportModeSelector(
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
                ),
                //* SELECCIÓN DE PREFERENCIAS DEL USUARIO (CHIPS)
                const SizedBox(height: 30),
                Text(
                  '¿Cuáles son tus intereses?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),

                Center(
                  child: TagWrap(
                    selectedPreferences: selectedPreferences,
                    onTagSelected: _onTagSelected,
                  ),
                ),

                //* SELECCIÓN DE TIEMPO MÁXIMO PARA LA RUTA (SLIDER)
                const SizedBox(height: 15),

                TimeSlider(
                  maxTimeInMinutes: maxTimeInMinutes,
                  onChanged: (double value) {
                    setState(() {
                      maxTimeInMinutes = value;
                    });
                    log.i(
                        'TourSelectionScreen: Tiempo máximo de ruta seleccionado: ${maxTimeInMinutes.round()} minutos');
                  },
                  formatTime: formatTime,
                ),

                //* BOTÓN DE PETICIÓN DE TOUR
                const SizedBox(height: 20),
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width - 60,
                  color: Theme.of(context).primaryColor,
                  elevation: 0,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  onPressed: () {
                    if (selectedPlace.isEmpty) {
                      selectedPlace = 'Salamanca, España';
                      log.w(
                          'TourSelectionScreen: Lugar vacío, usando "Salamanca, España" por defecto.');
                    }
                    final assistants = [
                      'Estás asistiendo a un progenitor, buscando lugares seguros, accesibles y entretenidos para los más pequeños, que también sean de interés para los adultos.',
                      'Asiste a una pareja en busca de experiencias románticas. Descripciones que buscan la complicidad y ambientes íntimos.',
                      'Pudieran ser grupos de amigos o personas con gustos más atrevidos. Respuestas más dinámicas y activas que sugieran lugares vibrantes.',
                    ];

                    final systemInstruction = selectedAssistant == null
                        ? ''
                        : assistants[selectedAssistant!];
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
                      maxTime: maxTimeInMinutes,
                      systemInstruction: systemInstruction,
                    ));

                    // Declaro el listener que se encargará de navegar al mapa cuando el tour se cargue
                    late StreamSubscription listener;
                    listener = BlocProvider.of<TourBloc>(context)
                        .stream
                        .listen((tourState) {
                      if (!mounted) return;

                      // Si el tour se carga correctamente
                      if (!tourState.isLoading &&
                          !tourState.hasError &&
                          tourState.ecoCityTour != null &&
                          context.mounted) {
                        Navigator.of(context).pop();
                        log.i(
                            'TourSelectionScreen: Tour cargado exitosamente, navegando al mapa.');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(tour: tourState.ecoCityTour!),
                          ),
                        );
                        listener.cancel(); // Cancelar el listener
                        return;
                      }

                      // Si hay un error, cierra el diálogo y muestra un error
                      if (tourState.hasError) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context)
                            .pop(); // Cerrar el diálogo de carga
                        log.e('TourSelectionScreen: Error al cargar el tour.');
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error al cargar el tour'),
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
      ),
    );
  }
}
