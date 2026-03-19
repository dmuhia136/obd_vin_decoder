import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

const String _resultNotApplicable = 'Not Applicable';

class NHTSA {
  static const String _uriBase = 'https://vpic.nhtsa.dot.gov/api/vehicles';

  /// Obtain information about a given [vin] from the NHTSA database.
  static Future<NHTSAVehicleInfo?> decodeVin(String vin) async {
    final url = Uri.parse('$_uriBase/DecodeVinValues/$vin?format=json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('Results') &&
            (data['Results'] as List).isNotEmpty) {
          return NHTSAVehicleInfo.fromJson(data['Results'][0]);
        }
      }
      return null;
    } catch (e, s) {
      log("NHTSA API Error: $e"); // Changed from print() to log()
      log("NHTSA API Stack Trace: $s");
      return null;
    }
  }
}

/// Extended vehicle information obtained from the NHTSA database.
class NHTSAVehicleInfo {
  final String? make;
  final String? model;
  final String? modelYear;
  final String? vehicleType;
  final String? engineCylinders;
  final String? displacementL;
  final String? trim;
  final String? plantCity;
  final String? plantCountry;

  NHTSAVehicleInfo({
    this.make,
    this.model,
    this.modelYear,
    this.vehicleType,
    this.engineCylinders,
    this.displacementL,
    this.trim,
    this.plantCity,
    this.plantCountry,
  });

  /// Safely extracts and normalizes the JSON payload
  factory NHTSAVehicleInfo.fromJson(Map<String, dynamic> json) {
    String? clean(String? value) {
      if (value == null ||
          value.trim().isEmpty ||
          value == _resultNotApplicable) {
        return null;
      }
      return value;
    }

    return NHTSAVehicleInfo(
      make: clean(json['Make']),
      model: clean(json['Model']),
      modelYear: clean(json['ModelYear']),
      vehicleType: clean(json['VehicleType']),
      engineCylinders: clean(json['EngineCylinders']),
      displacementL: clean(json['DisplacementL']),
      trim: clean(json['Trim']),
      plantCity: clean(json['PlantCity']),
      plantCountry: clean(json['PlantCountry']),
    );
  }

  @override
  String toString() {
    return '$modelYear $make $model'.trim();
  }
}
