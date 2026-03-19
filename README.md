# OBD VIN Decoder

A lightweight, reliable pure Dart VIN decoding utility that uses offline ISO 3779 mathematical standards and an NHTSA API fallback enhanced with modern 30-year cycle year mapping, region detection, manufacturer identification, and a built-in mock VIN generator. Includes real-time data fetching for Make, Model, Engine, Plant Location, and Trim.

## ✅ Features
* ✅ **Pure Dart:** Zero native code or permissions required.
* ✅ **Offline VIN decoding:** Zero latency.
* ✅ **Modern Year Support:** Accurately distinguishes 2001 vs 2031.
* ✅ **Manufacturer (WMI) identification**
* ✅ **Region & Country detection**
* ✅ **Online NHTSA API integration:** For extended data.
* ✅ **Random Mock VIN Generator:** Mathematically valid, perfect for testing.
* ✅ **Null-safe and strictly typed**
* ✅ **Cross-platform:** iOS, Android, Web, Mac, Windows, Linux.

---

## 🚀 Getting Started

### 1️⃣ Add Dependencies
In your `pubspec.yaml`:
```yaml
dependencies:
  obd_vin_decoder: ^0.0.1
2️⃣ Native Setup🎉 NONE! Because this package is written in pure Dart, you do not need to modify your AndroidManifest.xml or iOS Info.plist. It works out of the box on every platform.3️⃣ Import the PackageDartimport 'package:obd_vin_decoder/obd_vin_decoder.dart';
🧰 How to Use✅ Step 1: Initialize and ValidateDartfinal vehicle = VIN(number: '1HGCM82633A004XXX');

if (!vehicle.isValid()) {
  print('Invalid 17-character VIN!');
  return;
}
✅ Step 2: Offline Decoding (Zero Latency)Dartprint('Make: ${vehicle.getManufacturer()}'); // Honda
print('Year: ${vehicle.getYear()}');         // 2003
print('Region: ${vehicle.getRegion()}');     // North America
✅ Step 3: Fetch Extended Data (NHTSA API)Dartfinal info = await vehicle.getExtendedInfo();

if (info != null) {
  print('Model: ${info.model}');
  print('Engine: ${info.engineCylinders} Cylinders');
  print('Displacement: ${info.displacementL} L');
  print('Plant: ${info.plantCity}, ${info.plantCountry}');
}
✅ Step 4: Generate a Mock VIN (For Testing)DartString mockVin = VINGenerator.generate();
print('Generated VIN: $mockVin');
📦 NHTSAVehicleInfo DTODartclass NHTSAVehicleInfo {
  final String? make;
  final String? model;
  final String? modelYear;
  final String? vehicleType;
  final String? engineCylinders;
  final String? displacementL;
  final String? trim;
  final String? plantCity;
  final String? plantCountry;
  
  // Includes a fromJson factory and toString override
}
📍 Built-in VIN GeneratorThe package includes a highly advanced mock VIN generator (VINGenerator.generate()). It doesn't just output random strings; it calculates correct WMI codes, valid check digits, and purposefully alternates the 7th character (Letters/Numbers) to guarantee the generated VIN perfectly aligns with the ISO 30-year cycle rules.💡 Tips✅ Speed up your UI: Use the offline methods (getManufacturer(), getYear()) to update your UI instantly, then run getExtendedInfo() in the background to fill in the rest of the details once the API returns.🎯 NHTSA Limitations: The NHTSA database primarily focuses on vehicles manufactured for sale in North America. For JDM or purely European vehicles, rely on the offline decoder methods.🧠 Validation: Always call .isValid() before decoding to prevent processing incomplete barcodes or typed errors.🐛 TroubleshootingProblemSolutionisValid() returns falseEnsure the VIN is exactly 17 characters and does not contain the letters I, O, or Q.Year decodes incorrectlyEnsure the 7th character of the VIN is correct. The package uses this to determine if the car is pre-2010 or post-2010.API returns nullThe NHTSA server might be down, or the vehicle was not manufactured for the North American market. Fall back to offline methods.✅ Example IntegrationDartimport 'package:obd_vin_decoder/obd_vin_decoder.dart';

void main() async {
  // 1. Generate a test VIN
  String mockVin = VINGenerator.generate();
  print('Testing with VIN: $mockVin');

  // 2. Initialize
  final vehicle = VIN(number: detectedVin);

  if (vehicle.isValid()) {
  String make = vehicle.getManufacturer();
    String? model = vehicle.getModel(); // Instantly gets JDM models like "Prius"
    String year = vehicle.getYear()?.toString() ?? (vehicle.isJdm ? "JDM" : "Unknown");

    vehicleModelDetails.value = {
      "vin": detectedVin,
      "make": make,
      "model": model ?? "Standard",
      "year": year,
      "region": vehicle.getRegion(),
      "name": "$year $make ${model ?? ''}".trim(),
      "isJdm": vehicle.isJdm // You can even use this flag to show a "🇯🇵" icon in your UI!
    };
    
    // 3. Instant Offline Data
    print('--- OFFLINE DATA ---');
    print('Make: ${vehicle.getManufacturer()}');
    print('Year: ${vehicle.getYear()}');
    
    // 4. Detailed Online Data
    print('--- ONLINE DATA ---');
    final info = await vehicle.getExtendedInfo();
    
    if (info != null) {
      print('Model: ${info.model}');
      print('Type: ${info.vehicleType}');
    } else {
      print('No extended data found in NHTSA database.');
    }
  }
}
🔮 Coming Soon✅ European database fallback support❌ Specific brand decoders (e.g., decoding BMW option codes)❌ VIN Barcode / QR Scanner UI widget🤝 ContributingFeel free to fork the repo, submit PRs, or report issues. You can request:Additional offline WMI mappingsIntegrations with other regional transport APIs
## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  obd_vin_decoder: ^0.0.1