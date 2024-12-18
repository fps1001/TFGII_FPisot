import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla de selección de tour Eco City.
///
/// Permite a los usuarios configurar su experiencia, seleccionando lugar, número
/// de sitios, modo de transporte, tiempo máximo y preferencias personales.
class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  TourSelectionScreenState createState() => TourSelectionScreenState();
}

class TourSelectionScreenState extends State<TourSelectionScreen> {
  /// Lugar seleccionado por el usuario.
  String selectedPlace = '';

  /// Número de sitios a visitar.
  double numberOfSites = 2;

  /// Modo de transporte seleccionado.
  String selectedMode = 'walking';

  /// Estado del selector de modo de transporte.
  final List<bool> _isSelected = [true, false];

  /// Tiempo máximo permitido para la ruta en minutos.
  double maxTimeInMinutes = 90;

  /// Asistente seleccionado por el usuario (puede ser nulo).
  int? selectedAssistant;

  /// Preferencias seleccionadas por el usuario.
  final Map<String, bool> selectedPreferences = {
    'Naturaleza': false,
    'Museos': false,
    'Gastronomía': false,
    'Deportes': false,
    'Compras': false,
    'Historia': false,
  };

  /// Método para alternar el estado de las preferencias.
  void _onTagSelected(String key) {
    setState(() {
      selectedPreferences[key] = !selectedPreferences[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false, // Desactiva el botón de retroceso
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
          automaticallyImplyLeading: false, // Oculta el botón de retroceso
          actions: [
            IconButton(
              icon: const Icon(Icons.drive_file_move_rounded),
              tooltip: 'Cargar Ruta Guardada',
              onPressed: () async {
                BlocProvider.of<TourBloc>(context)
                    .add(const LoadSavedToursEvent());
                await Future.delayed(const Duration(milliseconds: 500));
                if (context.mounted) {
                  context.pushNamed('saved-tours');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: 'Ir al Wiki de la Aplicación',
              onPressed: _launchWikiURL,
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Oculta el teclado al tocar fuera
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 20.0,
              bottom: bottomInset, // Ajusta para el teclado
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de lugar
                Text(
                  '¿Qué lugar quieres visitar?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      selectedPlace = value;
                    });
                    log.i('Lugar seleccionado: $selectedPlace');
                  },
                  decoration: InputDecoration(
                    hintText: 'Introduce un lugar',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Número de sitios (Slider)
                NumberOfSitesSlider(
                  numberOfSites: numberOfSites,
                  onChanged: (value) {
                    setState(() {
                      numberOfSites = value;
                    });
                    log.i(
                        'Número de sitios seleccionado: ${numberOfSites.round()}');
                  },
                ),
                const SizedBox(height: 20),

                // Selección de asistente de IA
                SelectAIAssistant(
                  onAssistantSelected: (index) {
                    setState(() {
                      selectedAssistant = index;
                    });
                    log.i(
                        'Asistente seleccionado: ${index ?? "Sin selección"}');
                  },
                ),
                const SizedBox(height: 20),

                // Selector de modo de transporte
                TransportModeSelector(
                  isSelected: _isSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] = i == index;
                      }
                      selectedMode = index == 0 ? 'walking' : 'cycling';
                    });
                    log.i('Modo de transporte seleccionado: $selectedMode');
                  },
                ),
                const SizedBox(height: 30),

                // Preferencias del usuario (Chips)
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
                const SizedBox(height: 20),

                // Tiempo máximo para la ruta (Slider)
                TimeSlider(
                  maxTimeInMinutes: maxTimeInMinutes,
                  onChanged: (value) {
                    setState(() {
                      maxTimeInMinutes = value;
                    });
                    log.i(
                        'Tiempo máximo de ruta seleccionado: ${maxTimeInMinutes.round()} minutos');
                  },
                  formatTime: formatTime,
                ),
                const SizedBox(height: 20),

                // Botón para realizar la petición del tour
                MaterialButton(
                  minWidth: MediaQuery.of(context).size.width - 60,
                  color: Theme.of(context).primaryColor,
                  elevation: 0,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  onPressed: _requestTour,
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

  /// Realiza la petición del tour con los datos seleccionados.
  void _requestTour() {
    if (selectedPlace.isEmpty) {
      selectedPlace = 'Salamanca, España';
      log.w('Lugar vacío, usando "Salamanca, España" por defecto.');
    }

    final assistants = [
      'Lugares seguros y accesibles para familias.',
      'Experiencias románticas para parejas.',
      'Lugares vibrantes para aventureros.',
    ];
    final systemInstruction =
        selectedAssistant == null ? '' : assistants[selectedAssistant!];

    LoadingMessageHelper.showLoadingMessage(context);

    BlocProvider.of<TourBloc>(context).add(LoadTourEvent(
      mode: selectedMode,
      city: selectedPlace,
      numberOfSites: numberOfSites.round(),
      userPreferences: selectedPreferences.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      maxTime: maxTimeInMinutes,
      systemInstruction: systemInstruction,
    ));

    late StreamSubscription listener;
    listener = BlocProvider.of<TourBloc>(context).stream.listen((tourState) {
      if (!mounted) return;

      if (!tourState.isLoading &&
          !tourState.hasError &&
          tourState.ecoCityTour != null) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(tour: tourState.ecoCityTour!),
          ),
        );
        listener.cancel();
      }

      if (tourState.hasError) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar el tour')),
        );
        listener.cancel();
      }
    });
  }

  /// Abre la URL del wiki en el navegador.
  Future<void> _launchWikiURL() async {
    final Uri url = Uri.parse('https://github.com/fps1001/TFGII_FPisot/wiki');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir el enlace al Wiki: $url');
    }
  }
}
