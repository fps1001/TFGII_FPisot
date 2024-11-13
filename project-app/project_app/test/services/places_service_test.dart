import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/services/places_service.dart';

// Mock de Dio
class MockDio extends Mock implements Dio {}

void main() {
  late PlacesService placesService;
  late MockDio mockDio;

  setUpAll(() async {
    await dotenv.load();
    registerFallbackValue(Response(
      requestOptions: RequestOptions(path: ''),
      data: {},
    ));
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDio();
    // Inyectamos el mock de Dio al servicio.
    placesService = PlacesService(dio: mockDio);
  });

  group('PlacesService', () {
    test('searchPlace devuelve resultados cuando la respuesta es 200 y tiene datos', () async {
      // Configuramos la respuesta simulada
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'results': [
                    {
                      'name': 'Place Name',
                      'geometry': {'location': {'lat': 37.7749, 'lng': -122.4194}},
                      'formatted_address': 'Address',
                      'rating': 4.5,
                      'user_ratings_total': 100,
                      'photos': [],
                      'website': 'https://place.com'
                    },
                  ],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Llamamos al método `searchPlace` y verificamos los resultados.
      final result = await placesService.searchPlace('Place', 'City');

      expect(result, isNotNull);
      expect(result!['name'], 'Place Name');
      expect(result['location'], {'lat': 37.7749, 'lng': -122.4194});
      expect(result['formatted_address'], 'Address');
      expect(result['rating'], 4.5);
    });

    test('searchPlace maneja errores de red y devuelve null', () async {
      // Simulamos un error en la petición
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            error: 'Error',
          ));

      final result = await placesService.searchPlace('Place', 'City');

      // Verificamos que el resultado sea null, indicando que el error fue manejado correctamente.
      expect(result, isNull);
    });
  });
}
