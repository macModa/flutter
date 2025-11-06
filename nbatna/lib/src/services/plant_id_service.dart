import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/plante.dart';

class PlantIdService {
  static const String _apiUrl = 'https://api.plant.id/v3/identification';
  static const String _apiKey = 'O7vcxQzJuwKZ3zaTq9QNsyxx6wwuNZ7fZsJITHbTdDTckiBm3f';

  Future<PlantIdentification> identifyPlant(File imageFile) async {
    try {
      // Convertir l'image en base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Préparer la requête pour Plant.id v3
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _apiKey,
        },
        body: jsonEncode({
          'images': [base64Image],
          'similar_images': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return PlantIdentification.fromJson(jsonResponse);
      } else {
        throw Exception('فشل التعرف على النبات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخدمة: $e');
    }
  }
}
