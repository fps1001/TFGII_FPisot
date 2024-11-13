import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/optimization_service.dart';
import 'package:project_app/exceptions/exceptions.dart';

// Mock de Dio
class MockDio extends Mock implements Dio {}

void main() {
  late OptimizationService optimizationService;
  late MockDio mockDio;

  setUpAll(() async {
    registerFallbackValue(Response(
      requestOptions: RequestOptions(path: ''),
      data: {},
    ));
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() async {
    // Carga dotenv temporalmente con datos de prueba
    dotenv.testLoad(fileInput: '''GOOGLE_DIRECTIONS_API_KEY=test_key''');
    
    mockDio = MockDio();
    optimizationService = OptimizationService(dio: mockDio);
  });

  tearDown(() async {
    // Limpia dotenv después de cada prueba
    dotenv.clean();
  });

  group('OptimizationService - getOptimizedRoute', () {
    test('devuelve un EcoCityTour cuando la API responde correctamente', () async {
      final pois = [
        PointOfInterest(gps: const LatLng(37.7749, -122.4194), name: "Place A"),
        PointOfInterest(gps: const LatLng(37.7849, -122.4294), name: "Place B"),
      ];

      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'routes': [
                    {
                      'overview_polyline': {'points': 'abcd1234'},
                      'legs': [
                        {
                          'distance': {'value': 1000},
                          'duration': {'value': 600}
                        },
                        {
                          'distance': {'value': 1500},
                          'duration': {'value': 900}
                        },
                      ]
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await optimizationService.getOptimizedRoute(
        pois: pois,
        mode: 'walking',
        city: 'San Francisco',
        userPreferences: ['preference1', 'preference2'],
      );

      expect(result, isA<EcoCityTour>());
      expect(result.distance, 2500);
      expect(result.duration, 1500);
      expect(result.polilynePoints, isNotEmpty);
    });

    test('lanza AppException cuando no se encuentra la clave API', () async {
      // Limpia dotenv para simular la ausencia de la clave
      dotenv.clean();

      expect(
        () async => await optimizationService.getOptimizedRoute(
          pois: [],
          mode: 'walking',
          city: 'San Francisco',
          userPreferences: [],
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('lanza AppException cuando no se encuentran rutas en la respuesta', () async {
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'routes': []},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      expect(
        () async => await optimizationService.getOptimizedRoute(
          pois: [PointOfInterest(gps: const LatLng(37.7749, -122.4194), name: "Place A")],
          mode: 'driving',
          city: 'San Francisco',
          userPreferences: [],
        ),
        throwsA(isA<AppException>()),
      );
    });

   test('lanza FetchDataException cuando ocurre un error de red', () async {
  // Simula un error de red con DioException
  when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
      .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Error de red',
      ));

  expect(
    () async => await optimizationService.getOptimizedRoute(
      pois: [PointOfInterest(gps: const LatLng(37.7749, -122.4194), name: "Place A")],
      mode: 'bicycling',
      city: 'San Francisco',
      userPreferences: [],
    ),
    throwsA(isA<FetchDataException>()),  // Cambia DioException a FetchDataException
  );
});

  });
}
