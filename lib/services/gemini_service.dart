import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey = 'AIzaSyA1TmyLwnan8pPh5aaQI0ucTqYzZARn91c';

  late GenerativeModel model;
  late ChatSession chat;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 1024,
        responseMimeType: 'text/plain',
      ),
    );
    chat = model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    final content = Content.text(message);
    final response = await chat.sendMessage(content);
    return response.text;
  }
}
