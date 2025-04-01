import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:learn_n/services/api_key.dart';

class GeminiService {
  late GenerativeModel model;
  late ChatSession chat;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: APIKey.gemini,
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
