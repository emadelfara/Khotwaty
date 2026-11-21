import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import 'tracker_snapshot.dart';

class TrackerRepository {
  static const MethodChannel _channel = MethodChannel(AppConstants.trackerChannel);

  Future<TrackerSnapshot> getSnapshot() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getSnapshot');
      return result == null ? TrackerSnapshot.empty() : TrackerSnapshot.fromMap(result);
    } on PlatformException {
      return TrackerSnapshot.empty();
    }
  }

  Future<bool> start() async {
    try {
      return await _channel.invokeMethod<bool>('startTracking') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stopTracking');
    } on PlatformException {}
  }

  Future<bool> isSensorAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isSensorAvailable') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> saveProfile({required double heightCm, required double weightKg}) async {
    await _channel.invokeMethod<void>('saveProfile', {
      'heightCm': heightCm, 'weightKg': weightKg,
    });
  }
}
