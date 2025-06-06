import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:learn_n/services/api_key.dart';

class GeminiService {
  late GenerativeModel model;
  late ChatSession chat;

  GeminiService() {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: APIKey.gemini,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 564,
        responseMimeType: 'text/plain',
      ),
    );
    chat = model.startChat();
  }

  Future<String?> sendMessage(String message) async {
    final content = Content.text(message);
    final response = await chat.sendMessage(content);
    String? responseText = response.text;

    if (responseText != null) {
      // Apply formatting for bold, italic, and bold+italic text
      responseText = responseText.replaceAllMapped(
        RegExp(r'\*\*\*(.*?)\*\*\*'),
        (match) => '***${match[1]}***',
      );
      responseText = responseText.replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'),
        (match) => '**${match[1]}**',
      );
      responseText = responseText.replaceAllMapped(
        RegExp(r'\*(.*?)\*'),
        (match) => '*${match[1]}*',
      );
    }

    return responseText;
  }
}
