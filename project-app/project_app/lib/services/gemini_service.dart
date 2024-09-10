import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/models.dart';

class GeminiService {
  static Future<List<PointOfInterest>> fetchGeminiData() async {
    // Fetch data from Gemini API
    await dotenv.load();
    String geminiApi = dotenv.env['GEMINI_API_KEY'] ?? '';

    if (geminiApi.isEmpty) {
      print('No \$GEMINI_API_KEY environment variable');
      return [];
    }

    //* DEFINICIÓN DEL MODELO
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
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
          SchemaType.object,
          enumValues: [],
          properties: {
            "gps": Schema(
              SchemaType.array,
              items: Schema(
                SchemaType.number,
              ),
            ),
            "name": Schema(
              SchemaType.string,
            ),
            "description": Schema(
              SchemaType.string,
            ),
            "url": Schema(
              SchemaType.string,
            ),
            "url_img": Schema(
              SchemaType.string,
            ),
          },
          //* Campos requeridos
          requiredProperties: ['gps', 'name'],
        ),
    ),
    //* Role prompting: Se define el rol del modelo
    systemInstruction: Content.system('Eres un guía turístico comprometido con el medio ambiente preocupado por la gentrificación de las ciudades y el turismo masivo'),
  );

  //* Se le añade contexto al modelo dandole así también un ejemplo de lo que se espera de él: few-shot learning
  final chat = model.startChat(history: [
    Content.multi([
      TextPart('Genera una lista de 1 puntos de interés en Salamanca, incluyendo para cada uno: nombre, descripción breve, coordenadas GPS, una URL para más información y una URL de una imagen representativa. Organiza la información en formato JSON, con un array de objetos, donde cada objeto representa un punto de interés.'),
    ]),
    Content.model([
      TextPart('```json\n{"gps": [40.9647, -5.6695], "name": "Plaza Mayor", "description": "La Plaza Mayor de Salamanca es uno de los lugares más emblemáticos de la ciudad, un espacio público que ha sido testigo de la historia de la ciudad desde el siglo XVIII. Es un buen ejemplo de arquitectura barroca, y está rodeada de edificios con balcones que dan a la plaza.  Es un lugar perfecto para pasear, disfrutar de la gastronomía local y  observar el ambiente  de la ciudad. ", "url": "https://www.salamanca.es/es/turismo/plaza-mayor", "url_img": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Plaza_Mayor_de_Salamanca_%282015%29.jpg/1280px-Plaza_Mayor_de_Salamanca_%282015%29.jpg"\n} \n```'),
    ]),
  ]);
  //* CONSTRUCCIÓN DE PETICIÓN
  // Definimos las variables de ciudad y número de POIs
  //TODO Se obtendrán estas variables a través del bloc correspondiente, por ahora se definen de forma estática
  //TODO Las variables se modificarán en el menú de carga de la aplicación, pendiente de crear.
  final String ciudad = 'Salamanca';
  final int n_poi = 3;



  final message = '''Genera una lista de $n_poi puntos de interés en $ciudad, incluyendo para cada uno: nombre, descripción breve, coordenadas GPS, una URL para más información y una URL de una imagen representativa. Organiza la información en formato JSON, con un array de objetos, donde cada objeto representa un punto de interés.''';
  final content = Content.text(message);
  
  //* VALIDACIÓN E IMPRESIÓN DE RESPUESTA
  final response = await chat.sendMessage(content);

  if (response.text == null) {
      print('No response from the model.');
      return [];
    }

// Parsear la respuesta JSON para crear la lista de PointOfInterest
  List<PointOfInterest> pointsOfInterest = [];

  try {
      // Decodificar el JSON como un Map, ya que la estructura esperada no es una lista
      Map<String, dynamic> jsonResponse = json.decode(response.text!); // Decodificar el JSON

      // Verifica si hay un campo que contenga los puntos de interés como lista
      if (jsonResponse.containsKey('pointsOfInterest')) {
        List<dynamic> poisJson = jsonResponse['pointsOfInterest'];

        pointsOfInterest = poisJson.map((poiJson) {
          // Extraer las coordenadas GPS
          List<dynamic> gps = poiJson['gps'];
          LatLng gpsPoint = LatLng(gps[0].toDouble(), gps[1].toDouble());

          return PointOfInterest(
            gps: gpsPoint,
            name: poiJson['name'] ?? '',
            description: poiJson['description'],
            url: poiJson['url'],
            imageUrl: poiJson['url_img'],
          );
        }).toList();
      } else {
        // Si no hay un campo 'pointsOfInterest', extraer el único POI del JSON directamente
        //! CREO QUE ES EL CASO PORQUE GEMINI DEVUELVE UN SOLO POI
        //! TODO: FALLA LA SINTAXIS DE OPTIMIZACIÓN AL ENVIAR SOLO UN PAR DE COORDENADAS
        //* creo que hay que realizar una modificación en la petición para que devuelva un array de objetos y en caso de que sea solo uno hacer la validación.
        List<dynamic> gps = jsonResponse['gps'];
        LatLng gpsPoint = LatLng(gps[0].toDouble(), gps[1].toDouble());

        pointsOfInterest.add(PointOfInterest(
          gps: gpsPoint,
          name: jsonResponse['name'] ?? '',
          description: jsonResponse['description'],
          url: jsonResponse['url'],
          imageUrl: jsonResponse['url_img'],
        ));
      }
    } catch (e) {
      print('Error parsing response: $e');
    }

    return pointsOfInterest;
  }

  
  

  
}