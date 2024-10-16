import 'package:flutter/material.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar eventos y errores
import 'package:project_app/models/models.dart';
import 'package:project_app/blocs/blocs.dart';

class ExpandablePoiItem extends StatefulWidget {
  final PointOfInterest poi;
  final TourBloc tourBloc;

  const ExpandablePoiItem({
    super.key,
    required this.poi,
    required this.tourBloc,
  });

  @override
  ExpandablePoiItemState createState() => ExpandablePoiItemState();
}

class ExpandablePoiItemState extends State<ExpandablePoiItem> {
  bool isExpanded = false;
  late Future<Widget> _imageWidget;

  @override
  void initState() {
    super.initState();
    _imageWidget = _loadImage(); // Cargar la imagen del POI o de un asset
  }

  // Método para cargar la imagen del POI o usar un asset en caso de error
  Future<Widget> _loadImage() async {
    // Si la imagen URL no está disponible, cargar la imagen desde assets
    if (widget.poi.imageUrl == null) {
      log.w(
          'ExpandablePoiItem: No se encontró imagen para el POI ${widget.poi.name}, usando imagen predeterminada');
      return Image.asset(
        'assets/icon/icon.png',
        fit: BoxFit.cover,
      );
    } else {
      log.i('ExpandablePoiItem: Cargando imagen desde ${widget.poi.imageUrl}');
      return Image.network(
        widget.poi.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // En caso de error de carga, registrar el error y usar la imagen del troll
          log.e(
              'ExpandablePoiItem: Error al cargar la imagen desde ${widget.poi.imageUrl}',
              error: error,
              stackTrace: stackTrace);
          return Image.asset(
            'assets/location_troll_bg.png',
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // Imagen circular con borde verde
          Container(
            margin: const EdgeInsets.all(8), // Espaciado alrededor de la imagen
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green, // Borde verde
                width: 3, // Grosor del borde
              ),
              shape: BoxShape.circle, // Forma circular
            ),
            child: ClipOval(
              child: FutureBuilder<Widget>(
                future: _imageWidget,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  // Mostrar indicador de carga mientras se resuelve
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          // Expansión del texto del POI y botón eliminar al final
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 8),
              title: Text(
                widget.poi.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.poi.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${widget.poi.rating}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  // Mostrar solo una parte de la descripción si no está expandido
                  if (!isExpanded && widget.poi.description != null)
                    Text(
                      widget.poi.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Mostrar la descripción completa si está expandido
                  if (isExpanded && widget.poi.description != null)
                    Text(widget.poi.description!),
                ],
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Alternar expansión
                  log.i(
                      'ExpandablePoiItem: Descripción de ${widget.poi.name} ${isExpanded ? "expandida" : "colapsada"}');
                });
              },
            ),
          ),
          // Botón de eliminar ajustado a la derecha
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(),
            onPressed: () {
              log.i(
                  'ExpandablePoiItem: Eliminando POI ${widget.poi.name} del EcoCityTour');
              // Eliminar el POI sin actualizar el mapa
              widget.tourBloc.add(
                  OnRemovePoiEvent(poi: widget.poi, shouldUpdateMap: false));
            },
          ),
        ],
      ),
    );
  }
}
