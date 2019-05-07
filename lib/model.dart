import 'dart:ui';
import 'package:random_color/random_color.dart';

class Log {
  String name; int len; String date;
  Log(this.name, this.len, this.date);
}

class Sum {
  String name; int len; Color color;
  Sum(this.name, this.len) : color = RandomColor().randomColor();
}