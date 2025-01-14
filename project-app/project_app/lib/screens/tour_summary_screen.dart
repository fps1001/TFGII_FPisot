import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/helpers/helpers.dart'; // Importar el archivo de helpers
import 'package:project_app/ui/ui.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:project_app/blocs/blocs.dart';

/// Pantalla que muestra un resumen del **Eco City Tour** actual.
///
/// Permite visualizar información como la ciudad seleccionada, distancia,
/// duración, medio de transporte y los puntos de interés (POIs) del tour.
/// Además, ofrece la opción de **guardar el tour** con un nombre personalizado.
class TourSummaryScreen extends StatelessWidget {
  const TourSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.9;

    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        if (state.ecoCityTour == null) {
          _handleEmptyTour(context);
          return const SizedBox.shrink();
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              _buildSummaryCard(context, state, cardWidth),
              _buildPoiList(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Maneja el caso cuando el tour es nulo.
  void _handleEmptyTour(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CustomSnackbar.show(context, 'empty_tour_message'.tr());
      Navigator.pop(context);
    });
  }

  /// Construye el AppBar.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
      title: Text(
        'tour_summary_title'.tr(),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      actions: [_buildSaveTourButton(context)],
    );
  }

  /// Construye el botón para guardar el tour.
  Widget _buildSaveTourButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.save_as_rounded),
      tooltip: 'save_tour_tooltip'.tr(),
      onPressed: () => _showSaveTourDialog(context),
    );
  }

  /// Muestra el diálogo para guardar el tour.
  Future<void> _showSaveTourDialog(BuildContext context) async {
    final tourName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String inputText = '';
        return AlertDialog(
          title: Text('save_tour_name'.tr()),
          content: TextField(
            onChanged: (value) => inputText = value,
            decoration: InputDecoration(hintText: "save_tour_placeholder".tr()),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, inputText),
              child: Text('save_button'.tr()),
            ),
          ],
        );
      },
    );

    if (tourName != null && tourName.isNotEmpty && context.mounted) {
      await BlocProvider.of<TourBloc>(context).saveCurrentTour(tourName);
      if (context.mounted) {
        CustomSnackbar.show(context, 'tour_saved_success'.tr());
      }
    }
  }

  /// Construye la tarjeta de resumen del tour.
  Widget _buildSummaryCard(
      BuildContext context, TourState state, double cardWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Center(
        child: SizedBox(
          width: cardWidth,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCityInfo(state),
                  const SizedBox(height: 8),
                  _buildDistanceInfo(state),
                  const SizedBox(height: 4),
                  _buildDurationInfo(state),
                  const SizedBox(height: 4),
                  _buildTransportModeInfo(context, state),
                  const SizedBox(height: 8),
                  _buildUserPreferencesIcons(state),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la información de la ciudad.
  Widget _buildCityInfo(TourState state) {
    return Text(
      '${'city'.tr()}: ${state.ecoCityTour!.city}',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// Construye la información de la distancia.
  Widget _buildDistanceInfo(TourState state) {
    return Text(
      '${'distance'.tr()}: ${formatDistance(state.ecoCityTour!.distance ?? 0)}',
      style: const TextStyle(fontSize: 16),
    );
  }

  /// Construye la información de la duración.
  Widget _buildDurationInfo(TourState state) {
    return Text(
      '${'duration'.tr()}: ${formatDuration((state.ecoCityTour!.duration ?? 0).toInt())}',
      style: const TextStyle(fontSize: 16),
    );
  }

  /// Construye la información del modo de transporte.
  Widget _buildTransportModeInfo(BuildContext context, TourState state) {
    return Row(
      children: [
        Text('${'transport_mode'.tr()}:', style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Icon(
          transportIcons[state.ecoCityTour!.mode],
          size: 24,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  /// Construye los íconos de preferencias de usuario.
  Widget _buildUserPreferencesIcons(TourState state) {
    if (state.ecoCityTour!.userPreferences.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: state.ecoCityTour!.userPreferences.map((preference) {
        return _buildPreferenceIcon(preference);
      }).toList(),
    );
  }

  /// Construye un ícono de preferencia individual.
  Widget _buildPreferenceIcon(String preference) {
    final prefIconData = userPreferences[preference];
    if (prefIconData != null) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          prefIconData['icon'],
          color: prefIconData['color'],
          size: 24,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Construye la lista de puntos de interés.
  Widget _buildPoiList(BuildContext context, TourState state) {
    return Expanded(
      child: ListView.builder(
        itemCount: state.ecoCityTour!.pois.length,
        itemBuilder: (context, index) {
          final poi = state.ecoCityTour!.pois[index];
          return ExpandablePoiItem(
            poi: poi,
            tourBloc: BlocProvider.of<TourBloc>(context),
          );
        },
      ),
    );
  }
}
