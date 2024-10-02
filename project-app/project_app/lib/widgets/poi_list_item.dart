import 'package:flutter/material.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/helpers.dart';

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
              child: widget.poi.imageUrl != null
                  ? Image.network(
                      widget.poi.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child; // La imagen está completamente cargada
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).primaryColor,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        }
                      },
                    )
                  : const Icon(Icons.place, size: 60, color: Colors.grey),
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
                  if (!isExpanded && widget.poi.description != null)
                    Text(
                      widget.poi.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isExpanded && widget.poi.description != null)
                    Text(widget.poi.description!),
                ],
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded; // Alternar expansión
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
              // Mostrar el mensaje de carga antes de eliminar
              LoadingMessageHelper.showLoadingMessage(context);

              // Esperar un pequeño delay para simular una espera antes de la eliminación

              // Eliminar el POI y lanzar el evento en TourBloc
              widget.tourBloc.add(OnRemovePoiEvent(poi: widget.poi));

              // Cerrar el mensaje de carga
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
