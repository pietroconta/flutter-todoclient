import 'dart:ui';
import 'package:todo_client/utils/hex_color_extension.dart';
class TodoType {

  final int id;
  final Color color;
  final String description;

  TodoType({required this.id, required this.color, required this.description});
  

  factory TodoType.fromJson(Map<String, dynamic> json) {
    return TodoType(
      id: json['id'],
      color: (json['color'] as String).toColor(),
      description: json['description'],
    );
  }

}

