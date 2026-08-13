import 'dart:typed_data';
import 'package:gal/gal.dart';

void main() async {
  Uint8List bytes = Uint8List(0);
  await Gal.putImageBytes(bytes);
}
