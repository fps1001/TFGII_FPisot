import 'dart:convert';

class PlacesResponse {
    final List<Suggestion> suggestions;
    final String attribution;
    final String responseId;
    final String url;

    PlacesResponse({
        required this.suggestions,
        required this.attribution,
        required this.responseId,
        required this.url,
    });

    factory PlacesResponse.fromRawJson(String str) => PlacesResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PlacesResponse.fromJson(Map<String, dynamic> json) => PlacesResponse(
        suggestions: List<Suggestion>.from(json["suggestions"].map((x) => Suggestion.fromJson(x))),
        attribution: json["attribution"],
        responseId: json["response_id"],
        url: json["url"],
    );

    Map<String, dynamic> toJson() => {
        "suggestions": List<dynamic>.from(suggestions.map((x) => x.toJson())),
        "attribution": attribution,
        "response_id": responseId,
        "url": url,
    };
}

class Suggestion {
    final String name;
    final String mapboxId;
    final String featureType;
    final String address;
    final String fullAddress;
    final String placeFormatted;
    final Context context;
    final String language;
    final String maki;
    final List<String> poiCategory;
    final List<String> poiCategoryIds;
    final ExternalIds externalIds;
    final Metadata metadata;
    final int distance;
    final String operationalStatus;

    Suggestion({
        required this.name,
        required this.mapboxId,
        required this.featureType,
        required this.address,
        required this.fullAddress,
        required this.placeFormatted,
        required this.context,
        required this.language,
        required this.maki,
        required this.poiCategory,
        required this.poiCategoryIds,
        required this.externalIds,
        required this.metadata,
        required this.distance,
        required this.operationalStatus,
    });

    factory Suggestion.fromRawJson(String str) => Suggestion.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
        name: json["name"],
        mapboxId: json["mapbox_id"],
        featureType: json["feature_type"],
        address: json["address"],
        fullAddress: json["full_address"],
        placeFormatted: json["place_formatted"],
        context: Context.fromJson(json["context"]),
        language: json["language"],
        maki: json["maki"],
        poiCategory: List<String>.from(json["poi_category"].map((x) => x)),
        poiCategoryIds: List<String>.from(json["poi_category_ids"].map((x) => x)),
        externalIds: ExternalIds.fromJson(json["external_ids"]),
        metadata: Metadata.fromJson(json["metadata"]),
        distance: json["distance"],
        operationalStatus: json["operational_status"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "mapbox_id": mapboxId,
        "feature_type": featureType,
        "address": address,
        "full_address": fullAddress,
        "place_formatted": placeFormatted,
        "context": context.toJson(),
        "language": language,
        "maki": maki,
        "poi_category": List<dynamic>.from(poiCategory.map((x) => x)),
        "poi_category_ids": List<dynamic>.from(poiCategoryIds.map((x) => x)),
        "external_ids": externalIds.toJson(),
        "metadata": metadata.toJson(),
        "distance": distance,
        "operational_status": operationalStatus,
    };
}

class Context {
    final Country country;
    final Place postcode;
    final Place place;
    final Address? address;
    final Street street;

    Context({
        required this.country,
        required this.postcode,
        required this.place,
        this.address,
        required this.street,
    });

    factory Context.fromRawJson(String str) => Context.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Context.fromJson(Map<String, dynamic> json) => Context(
        country: Country.fromJson(json["country"]),
        postcode: Place.fromJson(json["postcode"]),
        place: Place.fromJson(json["place"]),
        address: json["address"] == null ? null : Address.fromJson(json["address"]),
        street: Street.fromJson(json["street"]),
    );

    Map<String, dynamic> toJson() => {
        "country": country.toJson(),
        "postcode": postcode.toJson(),
        "place": place.toJson(),
        "address": address?.toJson(),
        "street": street.toJson(),
    };
}

class Address {
    final String name;
    final String addressNumber;
    final String streetName;

    Address({
        required this.name,
        required this.addressNumber,
        required this.streetName,
    });

    factory Address.fromRawJson(String str) => Address.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"],
        addressNumber: json["address_number"],
        streetName: json["street_name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "address_number": addressNumber,
        "street_name": streetName,
    };
}

class Country {
    final String name;
    final String countryCode;
    final String countryCodeAlpha3;

    Country({
        required this.name,
        required this.countryCode,
        required this.countryCodeAlpha3,
    });

    factory Country.fromRawJson(String str) => Country.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Country.fromJson(Map<String, dynamic> json) => Country(
        name: json["name"],
        countryCode: json["country_code"],
        countryCodeAlpha3: json["country_code_alpha_3"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "country_code": countryCode,
        "country_code_alpha_3": countryCodeAlpha3,
    };
}

class Place {
    final Id id;
    final String name;

    Place({
        required this.id,
        required this.name,
    });

    factory Place.fromRawJson(String str) => Place.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Place.fromJson(Map<String, dynamic> json) => Place(
        id: idValues.map[json["id"]]!,
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": idValues.reverse[id],
        "name": name,
    };
}

enum Id {
    D_X_JU_OM1_IE_H_BS_YZP_BD_S9_J_UMC,
    D_X_JU_OM1_IE_H_BS_YZP_BOWV1_UMC,
    D_X_JU_OM1_IE_H_BS_YZP_BOWVP_UMC
}

final idValues = EnumValues({
    "dXJuOm1ieHBsYzpBdS9JUmc": Id.D_X_JU_OM1_IE_H_BS_YZP_BD_S9_J_UMC,
    "dXJuOm1ieHBsYzpBOWV1Umc": Id.D_X_JU_OM1_IE_H_BS_YZP_BOWV1_UMC,
    "dXJuOm1ieHBsYzpBOWVPUmc": Id.D_X_JU_OM1_IE_H_BS_YZP_BOWVP_UMC
});

class Street {
    final String name;

    Street({
        required this.name,
    });

    factory Street.fromRawJson(String str) => Street.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Street.fromJson(Map<String, dynamic> json) => Street(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class ExternalIds {
    final String? safegraph;
    final String? foursquare;

    ExternalIds({
        this.safegraph,
        this.foursquare,
    });

    factory ExternalIds.fromRawJson(String str) => ExternalIds.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ExternalIds.fromJson(Map<String, dynamic> json) => ExternalIds(
        safegraph: json["safegraph"],
        foursquare: json["foursquare"],
    );

    Map<String, dynamic> toJson() => {
        "safegraph": safegraph,
        "foursquare": foursquare,
    };
}

class Metadata {
    Metadata();

    factory Metadata.fromRawJson(String str) => Metadata.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    );

    Map<String, dynamic> toJson() => {
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
