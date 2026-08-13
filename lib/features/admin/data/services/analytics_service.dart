import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _initialized = false;
  Future<void>? _initializationFuture;

  Future<void> recordVisit() {
    if (_initialized) return Future.value();
    if (_initializationFuture != null) return _initializationFuture!;

    _initializationFuture = _initAnalytics();
    return _initializationFuture!;
  }

  Future<void> _initAnalytics() async {
    try {
      // Allow tracking in debug mode so the user can test it
      // if (!kReleaseMode) {
      //   debugPrint('Analytics: Skipping in non-release mode.');
      //   _initialized = true;
      //   return;
      // }

      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('analytics_device_id');

      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('analytics_device_id', deviceId);
      }

      final docRef = _firestore.collection('analytics_devices').doc(deviceId);
      final docSnapshot = await docRef.get();
      final now = DateTime.now();

      final statsRef = _firestore.collection('analytics').doc('stats');

      if (!docSnapshot.exists) {
        // First visit ever for this device
        await _firestore.runTransaction((transaction) async {
          transaction.set(docRef, {
            'deviceId': deviceId,
            'firstVisit': now.toIso8601String(),
            'lastVisit': now.toIso8601String(),
            'visitCount': 1,
            'platform': defaultTargetPlatform.name,
            'appVersion': '1.0.0', // Can be updated with package_info_plus
            'userAgent': kIsWeb ? 'Web Browser' : 'App',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

          transaction.set(
            statsRef,
            {
              'totalVisits': FieldValue.increment(1),
              'uniqueDevices': FieldValue.increment(1),
            },
            SetOptions(merge: true),
          );
        });
      } else {
        // Returning device
        final data = docSnapshot.data()!;
        final lastVisitStr = data['lastVisit'] as String?;
        if (lastVisitStr != null) {
          final lastVisit = DateTime.parse(lastVisitStr);
          final diff = now.difference(lastVisit);

          if (diff.inMinutes >= 1) {
            // More than 1 minute, count as new visit
            await _firestore.runTransaction((transaction) async {
              transaction.update(docRef, {
                'lastVisit': now.toIso8601String(),
                'visitCount': FieldValue.increment(1),
                'updatedAt': FieldValue.serverTimestamp(),
              });

              transaction.set(
                statsRef,
                {
                  'totalVisits': FieldValue.increment(1),
                },
                SetOptions(merge: true),
              );
            });
          } else {
              debugPrint(
              'Analytics: Visit skipped, less than 1 min since last visit.',
            );
          }
        }
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Analytics error: $e');
    } finally {
      _initializationFuture = null;
    }
  }
}
