import 'dart:io';
import 'package:path_provider/path_provider.dart';

get file async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/logs.txt');
}

void write(s) async {
  final f = await file; f.writeAsStringSync(s);
}