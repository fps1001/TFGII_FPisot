import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_app/models/place.dart';

class CustomBottomSheet extends StatelessWidget {
  final Place place;

  const CustomBottomSheet({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Este widget permitirá hacer scroll si es necesario
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text('LatLng(${place.location.latitude}, ${place.location.longitude})'),
            const SizedBox(height: 10.0),
            if (place.imageUrl != null)
              CachedNetworkImage(
                imageUrl: place.imageUrl!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 10.0),
            if (place.rating > 0) ...[
              Row(
                children: [
                  RatingBarIndicator(
                    rating: place.rating,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                  ),
                  const SizedBox(width: 10.0),
                  Text('(${place.userRatingsTotal} reviews)'),
                ],
              ),
              const SizedBox(height: 10.0),
            ],
            if (place.description != null) ...[
              Text(
                place.description!,
                style: const TextStyle(fontSize: 14.0, color: Colors.black54),
              ),
              const SizedBox(height: 10.0),
            ],
            if (place.websiteUri != null) ...[
              GestureDetector(
                onTap: () async {
                  final Uri url = Uri.parse(place.websiteUri!);
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
      ),
    );
  }
}
