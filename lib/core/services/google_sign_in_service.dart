// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// class GoogleSignInService {
//   static final GoogleSignIn _googleSignIn = GoogleSignIn(
//     serverClientId: AppStrings.googleServerClientId,
//   );

//   /// Signs in with Google and returns ID token only.
//   static Future<String> getIdToken() async {
//     try {
//       // Ensure we do not reuse an old session with a stale token audience.
//       await _googleSignIn.signOut();

//       final account = await _googleSignIn.signIn();
//       if (account == null) throw const UserCancelledException();

//       final auth = await account.authentication;
//       final idToken = auth.idToken;

//       if (idToken == null || idToken.isEmpty) {
//         throw const ServerException(
//           'Google sign-in failed: idToken was not returned. Check Google Web Client ID configuration.',
//         );
//       }

//       final audience = _extractJwtAudience(idToken);
//       _logGoogleToken(idToken: idToken, audience: audience);

//       if (audience != null && audience != AppStrings.googleServerClientId) {
//         throw ServerException(
//           'Google sign-in failed due to client-id mismatch. Token aud is $audience but app expects ${AppStrings.googleServerClientId}.',
//         );
//       }

//       return idToken;
//     } on PlatformException catch (e) {
//       if (_isCancelledPlatformException(e)) {
//         throw const UserCancelledException();
//       }
//       throw ServerException(_mapPlatformExceptionToMessage(e));
//     } on UserCancelledException {
//       rethrow;
//     } catch (e) {
//       throw ServerException(_mapUnknownExceptionToMessage(e));
//     }
//   }

//   static bool _isCancelledPlatformException(PlatformException e) {
//     final normalized = '${e.code} ${e.message ?? ''} ${e.details ?? ''}'
//         .toLowerCase();

//     return normalized.contains('12501') ||
//         normalized.contains('sign_in_canceled') ||
//         normalized.contains('sign in canceled') ||
//         normalized.contains('cancelled') ||
//         normalized.contains('canceled');
//   }

//   static String _mapPlatformExceptionToMessage(PlatformException e) {
//     final normalized = '${e.code} ${e.message ?? ''} ${e.details ?? ''}'
//         .toLowerCase();

//     if (normalized.contains('apiexception: 10') ||
//         normalized.contains('developer_error')) {
//       return 'Google sign-in is not configured for Android. In Google Cloud Console, create Android OAuth clients with package name ${AppStrings.androidApplicationId} and SHA-1 values: debug (${AppStrings.androidDebugSha1}) and release (${AppStrings.androidReleaseSha1}). Also ensure serverClientId is a Web OAuth client ID, not an Android client ID.';
//     }

//     if (normalized.contains('network_error') ||
//         normalized.contains('apiexception: 7')) {
//       return 'Google sign-in failed due to a network issue. Please check your connection and try again.';
//     }

//     return 'Google sign-in failed: ${e.message ?? e.code}';
//   }

//   static String _mapUnknownExceptionToMessage(Object e) {
//     final raw = e.toString();
//     final normalized = raw.toLowerCase();

//     // Some release builds return obfuscated ApiException strings like "w1.d: 10:".
//     if (normalized.contains('apiexception: 10') ||
//         normalized.contains('developer_error') ||
//         normalized.contains(': 10:')) {
//       return 'Google sign-in is not configured for Android. In Google Cloud Console, create Android OAuth clients with package name ${AppStrings.androidApplicationId} and SHA-1 values: debug (${AppStrings.androidDebugSha1}) and release (${AppStrings.androidReleaseSha1}). Also ensure serverClientId is a Web OAuth client ID, not an Android client ID.';
//     }

//     if (normalized.contains('apiexception: 7') ||
//         normalized.contains('network_error')) {
//       return 'Google sign-in failed due to a network issue. Please check your connection and try again.';
//     }

//     return 'Google sign-in failed: $raw';
//   }

//   static void _logGoogleToken({required String idToken, String? audience}) {
//     if (!kDebugMode) return;

//     debugPrint('=== Google Token Debug ===');
//     debugPrint('Configured serverClientId: ${AppStrings.googleServerClientId}');
//     debugPrint('ID Token aud: ${audience ?? 'unknown'}');
//     debugPrint('ID Token: $idToken');
//     debugPrint('==========================');
//   }

//   static String? _extractJwtAudience(String jwt) {
//     try {
//       final parts = jwt.split('.');
//       if (parts.length < 2) return null;

//       final payload = parts[1];
//       final normalized = base64Url.normalize(payload);
//       final decoded = utf8.decode(base64Url.decode(normalized));
//       final map = jsonDecode(decoded);
//       if (map is Map<String, dynamic>) {
//         final aud = map['aud'];
//         if (aud is String && aud.isNotEmpty) return aud;
//       }
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }

//   static Future<void> signOut() async {
//     await _googleSignIn.signOut();
//   }
// }
