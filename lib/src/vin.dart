import 'manufacturers.dart';
import 'year_map.dart';
import 'nhtsa_api.dart';
import 'cardog_api.dart';
import 'jdm_models.dart'; // <-- New Import

class VIN {
  /// The normalized alphanumeric string
  final String number;
  final String wmi;
  final String vds;
  final String vis;
  
  /// Flag to identify if the vehicle is a Japanese Domestic Market (JDM) import
  final bool isJdm;

  VIN({required String number})
      : number = _normalize(number),
        isJdm = _checkIfJdm(_normalize(number)),
        wmi = _normalize(number).length == 17 ? _normalize(number).substring(0, 3) : '',
        vds = _normalize(number).length == 17 ? _normalize(number).substring(3, 9) : '',
        vis = _normalize(number).length == 17 ? _normalize(number).substring(9, 17) : '';

  static String _normalize(String input) => input.toUpperCase().replaceAll('-', '');

  /// Checks if the chassis matches known JDM 10-13 character formats
  static bool _checkIfJdm(String normalized) {
    if (normalized.length >= 10 && normalized.length <= 13) {
      for (var prefix in jdmPrefixes.keys) {
        if (normalized.startsWith(prefix)) return true;
      }
    }
    return false;
  }

  /// Validates standard 17-character VINs OR recognized JDM chassis numbers
  bool isValid() {
    if (isJdm) return true;
    return RegExp(r"^[A-HJ-NPR-Z0-9]+$").hasMatch(number) && number.length == 17;
  }

  /// Gets the manufacturer (Make). Supports ISO WMI and JDM prefixes.
  String getManufacturer() {
    if (!isValid()) return "Invalid VIN";

    if (isJdm) {
      for (var entry in jdmPrefixes.entries) {
        if (number.startsWith(entry.key)) {
          return entry.value.split(' ')[0]; // Returns just the make, e.g., "Toyota"
        }
      }
    }

    if (manufacturers.containsKey(wmi)) return manufacturers[wmi]!;
    if (manufacturers.containsKey(wmi.substring(0, 2))) return manufacturers[wmi.substring(0, 2)]!;
    
    return "Unknown Make";
  }

  /// Get the specific Model (Highly accurate for JDM, returns null for standard VINs 
  /// since standard VIN models must be fetched via getExtendedInfo)
  String? getModel() {
    if (isJdm) {
      for (var entry in jdmPrefixes.entries) {
        if (number.startsWith(entry.key)) {
          // Removes the make and returns just the model, e.g., "Hiace / Regius"
          return entry.value.substring(entry.value.indexOf(' ') + 1).trim();
        }
      }
    }
    return null; 
  }

  /// Obtains the manufacturing year. Returns null for JDM as years are not encoded in the chassis string.
  int? getYear() {
    if (!isValid() || isJdm) return null;

    String yearChar = number[9]; 
    String cycleChar = number[6]; 
    bool isPre2010 = RegExp(r'[0-9]').hasMatch(cycleChar);

    return isPre2010 ? yearMapPre2010[yearChar] : yearMapPost2010[yearChar];
  }

  /// Obtains the 2-character region code
  String getRegion() {
    if (!isValid()) return "Unknown";
    if (isJdm) return "Asia (Japan)"; // Instant region lock for JDM
    
    final firstChar = number[0];
    if (RegExp(r"[A-H]").hasMatch(firstChar)) return "Africa";
    if (RegExp(r"[J-R]").hasMatch(firstChar)) return "Asia";
    if (RegExp(r"[S-Z]").hasMatch(firstChar)) return "Europe";
    if (RegExp(r"[1-5]").hasMatch(firstChar)) return "North America";
    if (RegExp(r"[6-7]").hasMatch(firstChar)) return "Oceania";
    if (RegExp(r"[8-9]").hasMatch(firstChar)) return "South America";
    
    return "Unknown Region";
  }

  /// Fetches extended vehicle info. Automatically skips NHTSA for JDM vehicles to save latency.
  Future<NHTSAVehicleInfo?> getExtendedInfo({String? fallbackApiUrl, String? fallbackApiKey}) async {
    if (!isValid()) return null;

    // 1. If it's JDM, NHTSA will fail anyway. Just return the offline data immediately as a DTO!
    if (isJdm) {
      return NHTSAVehicleInfo(
        make: getManufacturer(),
        model: getModel(),
        vehicleType: "JDM Import",
        plantCountry: "Japan",
      );
    }

    // 2. Try the Free US Government Database
    NHTSAVehicleInfo? info = await NHTSA.decodeVin(number);

    // 3. Trigger Fallback if NHTSA failed
    bool nhtsaFailed = info == null || info.make == null || info.make!.isEmpty;
    if (nhtsaFailed && fallbackApiUrl != null) {
      info = await CardogApi.decodeVin(number, fallbackApiUrl, apiKey: fallbackApiKey);
    }

    return info;
  }

  @override
  String toString() => number;
}



// import 'cardog_api.dart';
// import 'manufacturers.dart';
// // import 'year_map.dart';
// import 'nhtsa_api.dart';

// class VIN {
//   /// The raw 17-character VIN string
//   final String number;

//   /// The World Manufacturer Identifier (WMI)
//   final String wmi;

//   /// The Vehicle Descriptor Section (VDS)
//   final String vds;

//   /// The Vehicle Identifier Section (VIS)
//   final String vis;

//   /// Initializes and normalizes the VIN
//   VIN({required String number})
//     : number = _normalize(number),
//       wmi = _normalize(number).length == 17
//           ? _normalize(number).substring(0, 3)
//           : '',
//       vds = _normalize(number).length == 17
//           ? _normalize(number).substring(3, 9)
//           : '',
//       vis = _normalize(number).length == 17
//           ? _normalize(number).substring(9, 17)
//           : '';

//   /// Normalizes the string to uppercase and removes hyphens
//   static String _normalize(String input) =>
//       input.toUpperCase().replaceAll('-', '');

//   /// Validates standard 17-character alphanumeric VIN
//   bool isValid() {
//     return RegExp(r"^[A-HJ-NPR-Z0-9]+$").hasMatch(number) &&
//         number.length == 17;
//   }

//   /// Obtains the encoded manufacturing year (Now supports up to 2039)
//   // int? getYear() {
//   //   if (!isValid()) return null;

//   //   String yearChar = number[9]; // The 10th character defines the year
//   //   String cycleChar = number[6]; // The 7th character defines the cycle

//   //   // If the 7th character is a number, it's the pre-2010 cycle.
//   //   // If it's a letter, it's the post-2010 cycle.
//   //   bool isPre2010 = RegExp(r'[0-9]').hasMatch(cycleChar);

//   //   if (isPre2010) {
//   //     return yearMapPre2010[yearChar];
//   //   } else {
//   //     return yearMapPost2010[yearChar];
//   //   }
//   // }

//   /// Obtains the encoded manufacturing year using ISO 3779 algorithmic sequencing
//   int? getYear() {
//     if (!isValid()) return null;

//     // Standard VIN year sequence (30 character cycle)
//     const String sequence = "ABCDEFGHJKLMNPRSTVWXY123456789";
    
//     // number[9] is the 10th character (Year)
//     int index = sequence.indexOf(number[9]); 
//     if (index == -1) return null;

//     bool isNewEra = RegExp(r'[A-Z]').hasMatch(number[6]);

//     int baseYear = 1980 + index;
//     return isNewEra ? (baseYear + 30) : baseYear;
//   }

//   /// Obtains the 2-character region code for the manufacturing region
//   String getRegion() {
//     if (!isValid()) return "Unknown";

//     final firstChar = number[0];
//     if (RegExp(r"[A-H]").hasMatch(firstChar)) return "Africa";
//     if (RegExp(r"[J-R]").hasMatch(firstChar)) return "Asia";
//     if (RegExp(r"[S-Z]").hasMatch(firstChar)) return "Europe";
//     if (RegExp(r"[1-5]").hasMatch(firstChar)) return "North America";
//     if (RegExp(r"[6-7]").hasMatch(firstChar)) return "Oceania";
//     if (RegExp(r"[8-9]").hasMatch(firstChar)) return "South America";

//     return "Unknown Region";
//   }

//   /// Gets the full name of the vehicle manufacturer
//   String getManufacturer() {
//     if (!isValid()) return "Invalid VIN";

//     // Standard case - 3 character WMI
//     if (manufacturers.containsKey(wmi)) {
//       return manufacturers[wmi]!;
//     }

//     // Fallback case - 2 character WMI
//     final shortWmi = wmi.substring(0, 2);
//     if (manufacturers.containsKey(shortWmi)) {
//       return manufacturers[shortWmi]!;
//     }

//     return "Unknown (WMI: $wmi)";
//   }

//   /// Fetches extended vehicle info (Make, Model, Engine) from the NHTSA API
//  Future<NHTSAVehicleInfo?> getExtendedInfo({
//     String? fallbackApiKey
//   }) async {
//     if (!isValid()) return null;

//     // 1. Try the Free US Government Database First
//     NHTSAVehicleInfo? info = await NHTSA.decodeVin(number);

//     // 2. Check if NHTSA failed (Usually means it's a non-US market vehicle)
//     bool nhtsaFailed = info == null || info.make == null || info.make!.isEmpty;

//     // 3. Trigger Cardog Fallback if a URL was provided
//     if (nhtsaFailed) {
//       info = await CardogApi.decodeVin(number, "https://api.cardog.ai", apiKey: fallbackApiKey);
//     }

//     return info;
//   }

//   @override
//   String toString() => number;
// }
