import 'dart:convert';

class PlacesResponse {
  final String type;
  final List<String> query;
  final List<Feature> features;
  final String attribution;

  PlacesResponse({
    required this.type,
    required this.query,
    required this.features,
    required this.attribution,
  });

  factory PlacesResponse.fromRawJson(String str) =>
      PlacesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PlacesResponse.fromJson(Map<String, dynamic> json) => PlacesResponse(
        type: json["type"],
        query: List<String>.from(json["query"].map((x) => x)),
        features: List<Feature>.from(
            json["features"].map((x) => Feature.fromJson(x))),
        attribution: json["attribution"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "query": List<dynamic>.from(query.map((x) => x)),
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "attribution": attribution,
      };
}

class Feature {
  final String id;
  final String type;
  final List<String> placeType;
  final Properties properties;
  final String textEs;
  final Language? languageEs;
  final String placeNameEs;
  final String text;
  final Language? language;
  final String placeName;
  final List<double>? bbox;
  final List<double> center;
  final Geometry geometry;
  final List<Context> context;
  final String? matchingText;
  final String? matchingPlaceName;

  Feature({
    required this.id,
    required this.type,
    required this.placeType,
    required this.properties,
    required this.textEs,
    this.languageEs,
    required this.placeNameEs,
    required this.text,
    this.language,
    required this.placeName,
    this.bbox,
    required this.center,
    required this.geometry,
    required this.context,
    this.matchingText,
    this.matchingPlaceName,
  });

  factory Feature.fromRawJson(String str) => Feature.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json["id"],
        type: json["type"],
        placeType: List<String>.from(json["place_type"].map((x) => x)),
        properties: Properties.fromJson(json["properties"]),
        textEs: json["text_es"],
        languageEs: languageValues.map[json["language_es"]]!,
        placeNameEs: json["place_name_es"],
        text: json["text"],
        language: languageValues.map[json["language"]]!,
        placeName: json["place_name"],
        bbox: json["bbox"] == null
            ? []
            : List<double>.from(json["bbox"]!.map((x) => x?.toDouble())),
        center: List<double>.from(json["center"].map((x) => x?.toDouble())),
        geometry: Geometry.fromJson(json["geometry"]),
        context:
            List<Context>.from(json["context"].map((x) => Context.fromJson(x))),
        matchingText: json["matching_text"],
        matchingPlaceName: json["matching_place_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "place_type": List<dynamic>.from(placeType.map((x) => x)),
        "properties": properties.toJson(),
        "text_es": textEs,
        "language_es": languageValues.reverse[languageEs],
        "place_name_es": placeNameEs,
        "text": text,
        "language": languageValues.reverse[language],
        "place_name": placeName,
        "bbox": bbox == null ? [] : List<dynamic>.from(bbox!.map((x) => x)),
        "center": List<dynamic>.from(center.map((x) => x)),
        "geometry": geometry.toJson(),
        "context": List<dynamic>.from(context.map((x) => x.toJson())),
        "matching_text": matchingText,
        "matching_place_name": matchingPlaceName,
      };
}

class Context {
  final String id;
  final String mapboxId;
  final String? wikidata;
  final String? shortCode;
  final String textEs;
  final Language? languageEs;
  final String text;
  final Language? language;

  Context({
    required this.id,
    required this.mapboxId,
    this.wikidata,
    this.shortCode,
    required this.textEs,
    this.languageEs,
    required this.text,
    this.language,
  });

  factory Context.fromRawJson(String str) => Context.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Context.fromJson(Map<String, dynamic> json) => Context(
        id: json["id"],
        mapboxId: json["mapbox_id"],
        wikidata: json["wikidata"],
        shortCode: json["short_code"],
        textEs: json["text_es"],
        languageEs: languageValues.map[json["language_es"]]!,
        text: json["text"],
        language: languageValues.map[json["language"]]!,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mapbox_id": mapboxId,
        "wikidata": wikidata,
        "short_code": shortCode,
        "text_es": textEs,
        "language_es": languageValues.reverse[languageEs],
        "text": text,
        "language": languageValues.reverse[language],
      };
}

enum Language { ES }

final languageValues = EnumValues({"es": Language.ES});

class Geometry {
  final String type;
  final List<double> coordinates;

  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromRawJson(String str) =>
      Geometry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates:
            List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };
}

class Properties {
  final String? mapboxId;
  final String? wikidata;
  final String? foursquare;
  final bool? landmark;
  final String? address;
  final String? category;

  Properties({
    this.mapboxId,
    this.wikidata,
    this.foursquare,
    this.landmark,
    this.address,
    this.category,
  });

  factory Properties.fromRawJson(String str) =>
      Properties.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mapboxId: json["mapbox_id"],
        wikidata: json["wikidata"],
        foursquare: json["foursquare"],
        landmark: json["landmark"],
        address: json["address"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "wikidata": wikidata,
        "foursquare": foursquare,
        "landmark": landmark,
        "address": address,
        "category": category,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
