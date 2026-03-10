import 'dart:ui';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryDialCodeService {
  CountryDialCodeService._();

  static final CountryDialCodeService instance = CountryDialCodeService._();
  static const String _promptedKey = 'country_dial_code_prompted';
  static const String _cachedKey = 'country_dial_code_cached';
  static const String _cachedSourceKey = 'country_dial_code_cached_source';

  static const String _sourceLocation = 'location';
  static const String _sourceLocale = 'locale';

  Future<String?> suggestedPrefix() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedKey)?.trim() ?? '';
    final cachedSource = prefs.getString(_cachedSourceKey)?.trim() ?? '';
    if (cached.isNotEmpty) {
      final permission = await Geolocator.checkPermission();
      final hasLocationPermission =
          permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always;
      if (hasLocationPermission && cachedSource != _sourceLocation) {
        final refreshed = await _resolveAndPersist(
          prefs,
          allowLocation: true,
        );
        if (refreshed != null && refreshed.isNotEmpty) {
          return refreshed;
        }
      }
      return cached;
    }

    final bool alreadyPrompted = prefs.getBool(_promptedKey) ?? false;
    if (!alreadyPrompted) {
      await prefs.setBool(_promptedKey, true);
      final prefix = await _resolveAndPersist(prefs, allowLocation: true);
      if (prefix != null && prefix.isNotEmpty) {
        return prefix;
      }
    }

    return _resolveAndPersist(prefs, allowLocation: false);
  }

  Future<String?> cachedPrefix() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedKey)?.trim() ?? '';
    return cached.isEmpty ? null : cached;
  }

  Future<String?> refreshFromLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_promptedKey, true);
    return _resolveAndPersist(prefs, allowLocation: true);
  }

  Future<String?> _resolveAndPersist(
    SharedPreferences prefs, {
    required bool allowLocation,
  }) async {
    String? prefix;
    String? source;
    if (allowLocation) {
      prefix = await _resolveFromLocation();
      if (prefix != null && prefix.isNotEmpty) {
        source = _sourceLocation;
      }
    }
    prefix ??=
        _resolveFromCountryCode(PlatformDispatcher.instance.locale.countryCode);
    if (prefix != null && prefix.isNotEmpty) {
      source ??= _sourceLocale;
      await prefs.setString(_cachedKey, prefix);
      await prefs.setString(_cachedSourceKey, source);
    }
    return prefix;
  }

  Future<String?> _resolveFromLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {
        position = null;
      }
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        return null;
      }
      for (final placemark in placemarks) {
        final prefix = _resolveFromCountryCode(placemark.isoCountryCode);
        if (prefix != null && prefix.isNotEmpty) {
          return prefix;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _resolveFromCountryCode(String? countryCode) {
    if (countryCode == null || countryCode.trim().isEmpty) {
      return null;
    }
    return _dialCodes[countryCode.trim().toUpperCase()];
  }
}

const Map<String, String> _dialCodes = <String, String>{
  'AE': '+971',
  'AM': '+374',
  'AZ': '+994',
  'BY': '+375',
  'CA': '+1',
  'CN': '+86',
  'DE': '+49',
  'ES': '+34',
  'FR': '+33',
  'GB': '+44',
  'GE': '+995',
  'IN': '+91',
  'IT': '+39',
  'JP': '+81',
  'KG': '+996',
  'KR': '+82',
  'KZ': '+7',
  'PK': '+92',
  'RU': '+7',
  'SA': '+966',
  'TJ': '+992',
  'TM': '+993',
  'TR': '+90',
  'UA': '+380',
  'US': '+1',
  'UZ': '+998',
};
