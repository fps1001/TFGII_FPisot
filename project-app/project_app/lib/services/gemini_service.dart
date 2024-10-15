import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar errores
import 'package:project_app/models/models.dart';

class GeminiService {
  static Future<List<PointOfInterest>> fetchGeminiData({
    required String city,
    required int nPoi,
    required List<String> userPreferences,
    required double maxTime,
    required String mode,
  }) async {
    // Fetch data from Gemini API
    await dotenv.load();
    String geminiApi = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (geminiApi.isEmpty) {
      // Se registra el error si no se encuentra la clave API
      log.e(
          'GeminiService: No se encontró la variable de entorno \$GEMINI_API_KEY');
      return [];
    }

    //* DEFINICIÓN DEL MODELO
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: geminiApi,
      // safetySettings: Adjust safety settings
      // See https://ai.google.dev/gemini-api/docs/safety-settings
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        //* TOOL CALLING: Se solicita la respuesta en formato JSON
        responseMimeType: 'application/json',

        responseSchema: Schema(
          SchemaType.array, // Cambiamos a array porque esperamos múltiples POIs
          items: Schema(
            SchemaType.object,
            properties: {
              "gps": Schema(SchemaType.array, items: Schema(SchemaType.number)),
              "name": Schema(SchemaType.string),
              "description": Schema(SchemaType.string),
            },
            requiredProperties: ['gps', 'name'],
          ),
        ),
      ),
      //* Role prompting: Se define el rol del modelo
      systemInstruction: Content.system(
          'Eres un guía turístico comprometido con el medio ambiente preocupado por la gentrificación de las ciudades y el turismo masivo'),
    );

    //* CONSTRUCCIÓN DE PETICIÓN

    final medioTransporte = (mode == 'walking' ? 'andando' : 'en bicicleta');

    final chat = model.startChat();

    final message =
        '''Genera un array de $nPoi objetos JSON, cada uno representando un punto de interés turístico diferente en $city. 
Además, no sirve cualquier lugar, puesto que el tiempo que se tarde en viajar entre ellos no debe ser superior en ningún momento a $maxTime minutos $medioTransporte.
Cada objeto debe incluir:
* nombre (string)
* descripción (string)
* coordenadas (array de dos números: latitud y longitud)


**Ejemplo de objeto JSON:**
```json
{
    "nombre": "Plaza Mayor",
    "descripcion": "La Plaza Mayor de Salamanca, del siglo XVIII, es una de las más bellas plazas monumentales urbanas de Europa. Comenzó a construirse en 1729 a instancias del corregidor Rodrigo Caballero Llanes. El proyecto fue a cargo del arquitecto Alberto de Churriguera, al que siguió su sobrino Manuel de Lara Churriguera y fue finalizado por Andrés García de Quiñones en 1755. ...",
    "coordenadas": [40.965027795465176, -5.664062074092496],
}
Ten en cuenta los siguientes intereses del usuario: ${userPreferences.join(', ')}.

''';

    final content = Content.text(message);

    //* VALIDACIÓN E IMPRESIÓN DE RESPUESTA
    final response = await chat.sendMessage(content);

    if (response.text == null) {
      // Log si el modelo no da respuesta
      log.w('GeminiService: No se recibió respuesta del modelo.');
      return [];
    }

    // Parsear la respuesta JSON para crear la lista de PointOfInterest
    List<PointOfInterest> pointsOfInterest = [];

    try {
      // Decodificar el JSON como una lista de mapas
      List<dynamic> jsonResponse =
          json.decode(response.text!); // Decodificar el JSON como lista

      // Mapear los datos del JSON a una lista de objetos PointOfInterest
      pointsOfInterest = jsonResponse.map((poiJson) {
        List<dynamic> gps = poiJson['gps'];
        LatLng gpsPoint = LatLng(gps[0].toDouble(), gps[1].toDouble());

        return PointOfInterest(
          gps: gpsPoint,
          name: poiJson['name'] ?? '',
          description: poiJson['description'],
        );
      }).toList();
      log.i(
          'GeminiService: Se obtuvieron ${pointsOfInterest.length} puntos de interés en $city');
    } catch (e, stackTrace) {
      log.e('GeminiService: Error al parsear la respuesta JSON',
          error: e, stackTrace: stackTrace);
    }
    return pointsOfInterest;
  }
}
