import 'dart:convert';

class TrafficResponse {
  List<Route> routes;
  List<Waypoint> waypoints;
  String code;
  String uuid;

  TrafficResponse({
    required this.routes,
    required this.waypoints,
    required this.code,
    required this.uuid,
  });

  factory TrafficResponse.fromMap(Map<String, dynamic> map) {
    return TrafficResponse(
      routes: List<Route>.from(map['routes']?.map((x) => Route.fromMap(x))),
      waypoints: List<Waypoint>.from(
          map['waypoints']?.map((x) => Waypoint.fromMap(x))),
      code: map['code'],
      uuid: map['uuid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routes': routes.map((x) => x.toMap()).toList(),
      'waypoints': waypoints.map((x) => x.toMap()).toList(),
      'code': code,
      'uuid': uuid,
    };
  }

  factory TrafficResponse.fromJson(String source) =>
      TrafficResponse.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}

class Route {
  String weightName;
  double weight;
  double duration;
  double distance;
  List<Leg> legs;
  String geometry;

  Route({
    required this.weightName,
    required this.weight,
    required this.duration,
    required this.distance,
    required this.legs,
    required this.geometry,
  });

  factory Route.fromMap(Map<String, dynamic> map) {
    return Route(
      weightName: map['weight_name'],
      weight: map['weight'].toDouble(),
      duration: map['duration'].toDouble(),
      distance: map['distance'].toDouble(),
      legs: List<Leg>.from(map['legs']?.map((x) => Leg.fromMap(x))),
      geometry: map['geometry'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weight_name': weightName,
      'weight': weight,
      'duration': duration,
      'distance': distance,
      'legs': legs.map((x) => x.toMap()).toList(),
      'geometry': geometry,
    };
  }
}

class Leg {
  List<dynamic> viaWaypoints;
  List<Admin> admins;
  double weight;
  double duration;
  List<dynamic> steps;
  double distance;
  String summary;

  Leg({
    required this.viaWaypoints,
    required this.admins,
    required this.weight,
    required this.duration,
    required this.steps,
    required this.distance,
    required this.summary,
  });

  factory Leg.fromMap(Map<String, dynamic> map) {
    return Leg(
      viaWaypoints: List<dynamic>.from(map['via_waypoints']),
      admins: List<Admin>.from(map['admins']?.map((x) => Admin.fromMap(x))),
      weight: map['weight'].toDouble(),
      duration: map['duration'].toDouble(),
      steps: List<dynamic>.from(map['steps']),
      distance: map['distance'].toDouble(),
      summary: map['summary'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'via_waypoints': viaWaypoints,
      'admins': admins.map((x) => x.toMap()).toList(),
      'weight': weight,
      'duration': duration,
      'steps': steps,
      'distance': distance,
      'summary': summary,
    };
  }
}

class Admin {
  String iso31661Alpha3;
  String iso31661;

  Admin({
    required this.iso31661Alpha3,
    required this.iso31661,
  });

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      iso31661Alpha3: map['iso_3166_1_alpha3'],
      iso31661: map['iso_3166_1'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'iso_3166_1_alpha3': iso31661Alpha3,
      'iso_3166_1': iso31661,
    };
  }
}

class Waypoint {
  double distance;
  String name;
  List<double> location;

  Waypoint({
    required this.distance,
    required this.name,
    required this.location,
  });

  factory Waypoint.fromMap(Map<String, dynamic> map) {
    return Waypoint(
      distance: map['distance'].toDouble(),
      name: map['name'],
      location: List<double>.from(map['location']?.map((x) => x.toDouble())),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'distance': distance,
      'name': name,
      'location': location,
    };
  }
}
