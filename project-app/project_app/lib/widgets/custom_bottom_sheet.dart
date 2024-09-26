import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_app/models/models.dart'; // Asegúrate de que este archivo importe el modelo PointOfInterest

class CustomBottomSheet extends StatelessWidget {
  final PointOfInterest poi;  // Cambiamos Place por PointOfInterest

  const CustomBottomSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del lugar (POI)
          Text(
            poi.name,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),

          // Coordenadas del POI
          Text('LatLng(${poi.gps.latitude}, ${poi.gps.longitude})'),
          const SizedBox(height: 10.0),

          // Imagen del POI si está disponible
          if (poi.imageUrl != null)
            CachedNetworkImage(
              imageUrl: poi.imageUrl!,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 10.0),

          // Rating si está disponible
          if (poi.rating != null && poi.rating! > 0) ...[
            Row(
              children: [
                RatingBarIndicator(
                  rating: poi.rating!,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                const SizedBox(width: 10.0),
                // Puedes agregar el número de reseñas si está disponible
                Text('(Rating: ${poi.rating})'),
              ],
            ),
            const SizedBox(height: 10.0),
          ],

          // Descripción del POI si está disponible
          if (poi.description != null) ...[
            Text(
              poi.description!,
              style: const TextStyle(fontSize: 14.0, color: Colors.black54),
            ),
            const SizedBox(height: 10.0),
          ],

          // Enlace al sitio web del POI si está disponible
          if (poi.url != null) ...[
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(poi.url!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: const Text(
                'Visita la página web',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ],
      ),
    );
  }
}
