import 'dart:typed_data';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadImage(Uint8List bytes, String fileName) async {
  final base64data = base64Encode(bytes);
  final a = html.AnchorElement(href: 'data:image/png;base64,$base64data');
  a.download = fileName;
  a.click();
  a.remove();
}
