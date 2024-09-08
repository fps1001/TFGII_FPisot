// Version: 1.0
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  String geminiApi = dotenv.env['GEMINI_API_KEY'] ?? '';

  if (geminiApi == '') {
    print('No \$API_KEY environment variable');
    exit(1);
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
      responseMimeType: 'application/json',
        //* TOOL CALLING: Se solicita la respuesta en formato JSON
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
          requiredProperties: ['gps', 'name'],
        ),
    ),
    systemInstruction: Content.system('Eres un guía turístico comprometido con el medio ambiente preocupado por la gentrificación de las ciudades y el turismo masivo'),
  );

  final chat = model.startChat(history: [
    Content.multi([
      TextPart('Dime tres puntos de interés que deba visitar en Salamanca'),
    ]),
    Content.model([
      TextPart('```json\n{"gps": [40.9647, -5.6695], "name": "Plaza Mayor", "description": "La Plaza Mayor de Salamanca es uno de los lugares más emblemáticos de la ciudad, un espacio público que ha sido testigo de la historia de la ciudad desde el siglo XVIII. Es un buen ejemplo de arquitectura barroca, y está rodeada de edificios con balcones que dan a la plaza.  Es un lugar perfecto para pasear, disfrutar de la gastronomía local y  observar el ambiente  de la ciudad. ", "url": "https://www.salamanca.es/es/turismo/plaza-mayor", "url_img": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Plaza_Mayor_de_Salamanca_%282015%29.jpg/1280px-Plaza_Mayor_de_Salamanca_%282015%29.jpg"\n} \n```'),
    ]),
  ]);
  final message = 'INSERT_INPUT_HERE';
  final content = Content.text(message);
  
  //* IMPRESIÓN DE LA RESPUESTA
  final response = await chat.sendMessage(content);
  print(response.text);

//Contamos los tokens para controlar el uso de la API
final tokenCount = await model.countTokens([Content.text(message)]);
print('Token count: ${tokenCount.totalTokens}');

}

//TODO https://ai.google.dev/gemini-api/docs/function-calling/tutorial?lang=dart&hl=es-419 Comprobar la posibilidad de realizar llamadas a funciones