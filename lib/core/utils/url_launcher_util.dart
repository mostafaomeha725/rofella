import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtil {
  static Future<void> launchAnyUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $urlString';
    }
  }

  static Future<void> launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  static Future<void> launchEmail(String postEmail) async {
    Uri email = Uri(
      scheme: 'mailto',
      path: postEmail,
      query: Uri.encodeQueryComponent('subject=Testing subject'),
    );
    bool canLaunch = await canLaunchUrl(email);
    debugPrint('Can launch email: $canLaunch'); // Debug line

    if (canLaunch) {
      await launchUrl(email, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $email');
    }
  }

  static Future<void> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    // Format the phone properly (ensure it starts with + if missing, or handle properly)
    String formattedPhone = phone.startsWith('+') ? phone : '+$phone';

    final String cleanPhone = formattedPhone.replaceAll('+', '');
    
    Uri whatsappUri;
    
    if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
      whatsappUri = Uri(
        scheme: 'whatsapp',
        host: 'send',
        queryParameters: {
          'phone': formattedPhone,
          'text': message,
        },
      );
    } else {
      whatsappUri = Uri(
        scheme: 'https',
        host: 'api.whatsapp.com',
        path: 'send',
        queryParameters: {
          'phone': cleanPhone,
          'text': message,
        },
      );
    }

    bool canLaunchWhatsApp = await canLaunchUrl(whatsappUri);
    debugPrint('Can launch WhatsApp: $canLaunchWhatsApp');

    if (canLaunchWhatsApp) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      // As a final fallback for some devices, try to launch regardless
      try {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        throw Exception('Could not launch WhatsApp');
      }
    }
  }

  static Future<bool> launchMap({
    required double latitude,
    required double longitude,
  }) async {
    final destination = '$latitude,$longitude';
    final appUri = Uri.parse('google.navigation:q=$destination&mode=d');
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving',
    );

    var launched = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }

    return launched;
  }
}
