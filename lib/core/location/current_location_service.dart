import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationResult {
  const CurrentLocationResult({
    required this.latitude,
    required this.longitude,
    this.street,
    this.city,
    this.state,
    this.postalCode,
  });

  final double latitude;
  final double longitude;
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;

  String get summary => [
    if (street != null && street!.isNotEmpty) street,
    if (city != null && city!.isNotEmpty) city,
    if (state != null && state!.isNotEmpty) state,
  ].whereType<String>().join(', ');
}

class CurrentLocationService {
  const CurrentLocationService();

  Future<CurrentLocationResult> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailableException(
        'Turn on your device location services, then try again.',
        canOpenSettings: true,
        openLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationUnavailableException(
        'Location permission was denied. You can enter the address manually.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableException(
        'Location permission is blocked. Allow it in your device settings to use this feature.',
        canOpenSettings: true,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.isEmpty ? null : placemarks.first;
    final street = [
      place?.subThoroughfare,
      place?.thoroughfare,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');

    return CurrentLocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      street: street.isEmpty ? null : street,
      city: _firstNonEmpty([
        place?.locality,
        place?.subAdministrativeArea,
        place?.subLocality,
      ]),
      state: _firstNonEmpty([place?.administrativeArea]),
      postalCode: _firstNonEmpty([place?.postalCode]),
    );
  }

  String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class LocationUnavailableException implements Exception {
  const LocationUnavailableException(
    this.message, {
    this.canOpenSettings = false,
    this.openLocationSettings = false,
  });

  final String message;
  final bool canOpenSettings;
  final bool openLocationSettings;
}
