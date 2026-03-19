import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nhtsa_api.dart';

class CardogApi {
  /// Decode a VIN using the Cardog API
  static Future<NHTSAVehicleInfo?> decodeVin(String vin, String apiUrl, {String? apiKey}) async {
    try {
      final uri = Uri.parse('$apiUrl/vin/corgi/$vin');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // Add API key if configured
      if (apiKey != null && apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Corgi usually nests vehicle data inside data.components.vehicle
        final vehicleData = data['components']?['vehicle'] ?? data;

        // Map it directly to our existing DTO so the frontend doesn't break
        return NHTSAVehicleInfo(
          make: vehicleData['make']?.toString(),
          model: vehicleData['model']?.toString(),
          modelYear: vehicleData['year']?.toString() ?? vehicleData['modelYear']?.toString(),
          vehicleType: vehicleData['bodyStyle']?.toString() ?? vehicleData['vehicleType']?.toString(),
          engineCylinders: vehicleData['engineCylinders']?.toString(),
          displacementL: vehicleData['displacementL']?.toString(),
          trim: vehicleData['trim']?.toString(),
          plantCity: vehicleData['plantCity']?.toString(),
          plantCountry: vehicleData['plantCountry']?.toString(),
        );
      }
      return null;
    } catch (e) {
      // Fail silently and return null so the app doesn't crash
      return null;
    }
  }
}