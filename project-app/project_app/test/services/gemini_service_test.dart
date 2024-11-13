import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/gemini_service.dart';

void main() {
  setUp(() async {
    // Cargar dotenv en cada test con la API Key configurada
    dotenv.testLoad(fileInput: '''
      GEMINI_API_KEY=your_gemini_api_key
    ''');
  });

  tearDown(() async {
    // Limpiar dotenv después de cada test para evitar "filtraciones"
    dotenv.testLoad(fileInput: '''
      # No se define GEMINI_API_KEY
    ''');
  });

  group('GeminiService - fetchGeminiData', () {
    test('devuelve una lista de PointOfInterest cuando el modelo responde correctamente', () async {
      const city = "San Francisco";
      const nPoi = 3;
      const maxTime = 15.0;
      const mode = 'walking';
      final userPreferences = ['arte', 'museos'];

      final result = await GeminiService.fetchGeminiData(
        city: city,
        nPoi: nPoi,
        userPreferences: userPreferences,
        maxTime: maxTime,
        mode: mode,
      );

      expect(result, isA<List<PointOfInterest>>());
      expect(result.length, nPoi); // Se espera que devuelva `nPoi` elementos si es exitoso
    });
  });
}
