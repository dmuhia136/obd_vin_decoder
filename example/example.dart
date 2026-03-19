 // ignore_for_file: avoid_print

import 'package:obd_vin_decoder/obd_vin_decoder.dart';

void main() async {
  print('=======================================');
  print('🚗 OBD VIN DECODER - USAGE EXAMPLE 🚗');
  print('=======================================\n');

  // ---------------------------------------------------------
  // 1. GENERATE A MOCK VIN
  // ---------------------------------------------------------
  print('--- 1. Generating a Mock VIN ---');
  String mockVinString = VINGenerator.generate();
  print('Generated 17-Character VIN: $mockVinString\n');

  // ---------------------------------------------------------
  // 2. OFFLINE DECODING (Zero Latency)
  // ---------------------------------------------------------
  print('--- 2. Offline Decoding ---');
  final vehicle = VIN(number: mockVinString);

  if (vehicle.isValid()) {
    print('✅ Valid VIN format');
    print('🏢 Manufacturer : ${vehicle.getManufacturer()}');
    print('📅 Year         : ${vehicle.getYear()}');
    print('🌍 Region       : ${vehicle.getRegion()}');
  } else {
    print('❌ Invalid VIN format');
  }
  print('\n');

  // ---------------------------------------------------------
  // 3. ONLINE DECODING (NHTSA API)
  // ---------------------------------------------------------
  print('--- 3. Online Decoding (NHTSA API) ---');
  
  // We use a known real-world VIN here because the US Government database 
  // might return "null" for the randomly generated mock VIN above.
  final realVehicle = VIN(number: '1HGCM82633A004XXX'); // Example Honda VIN
  
  print('📡 Fetching extended data for ${realVehicle.number}...');
  
  final info = await realVehicle.getExtendedInfo();

  if (info != null) {
    print('🚘 Make       : ${info.make}');
    print('🚙 Model      : ${info.model}');
    print('⚙️  Engine     : ${info.engineCylinders} Cylinders');
    print('🏭 Plant City : ${info.plantCity ?? "Unknown"}');
  } else {
    print('⚠️ Could not fetch extended info (API might be down).');
  }
  
  print('\n=======================================');
}
