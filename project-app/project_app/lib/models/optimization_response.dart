import 'dart:convert';

import 'models.dart';

class OptimizationResponse {
    final String code;
    final List<Waypoint> waypoints;
    final List<Trip> trips;

    OptimizationResponse({
        required this.code,
        required this.waypoints,
        required this.trips,
    });

    factory OptimizationResponse.fromRawJson(String str) => OptimizationResponse.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory OptimizationResponse.fromJson(Map<String, dynamic> json) => OptimizationResponse(
        code: json["code"],
        waypoints: List<Waypoint>.from(json["waypoints"].map((x) => Waypoint.fromJson(x))),
        trips: List<Trip>.from(json["trips"].map((x) => Trip.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
        "trips": List<dynamic>.from(trips.map((x) => x.toJson())),
    };
}

class Trip {
    final String geometry;
    final List<Leg> legs;
    final String weightName;
    final double weight;
    final double duration;
    final double distance;

    Trip({
        required this.geometry,
        required this.legs,
        required this.weightName,
        required this.weight,
        required this.duration,
        required this.distance,
    });

    factory Trip.fromRawJson(String str) => Trip.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        geometry: json["geometry"],
        legs: List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
        weightName: json["weight_name"],
        weight: json["weight"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        distance: json["distance"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "geometry": geometry,
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "weight_name": weightName,
        "weight": weight,
        "duration": duration,
        "distance": distance,
    };
}

/* class Leg {
    final List<dynamic> steps;
    final String summary;
    final double weight;
    final double duration;
    final double distance;

    Leg({
        required this.steps,
        required this.summary,
        required this.weight,
        required this.duration,
        required this.distance,
    });

    factory Leg.fromRawJson(String str) => Leg.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        steps: List<dynamic>.from(json["steps"].map((x) => x)),
        summary: json["summary"],
        weight: json["weight"]?.toDouble(),
        duration: json["duration"]?.toDouble(),
        distance: json["distance"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "steps": List<dynamic>.from(steps.map((x) => x)),
        "summary": summary,
        "weight": weight,
        "duration": duration,
        "distance": distance,
    };
} 

class Waypoint {
    final double distance;
    final String name;
    final List<double> location;
    final int waypointIndex;
    final int tripsIndex;

    Waypoint({
        required this.distance,
        required this.name,
        required this.location,
        required this.waypointIndex,
        required this.tripsIndex,
    });

    factory Waypoint.fromRawJson(String str) => Waypoint.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        distance: json["distance"]?.toDouble(),
        name: json["name"],
        location: List<double>.from(json["location"].map((x) => x?.toDouble())),
        waypointIndex: json["waypoint_index"],
        tripsIndex: json["trips_index"],
    );

    Map<String, dynamic> toJson() => {
        "distance": distance,
        "name": name,
        "location": List<dynamic>.from(location.map((x) => x)),
        "waypoint_index": waypointIndex,
        "trips_index": tripsIndex,
    };
}
*/