import 'dart:ui';
import 'package:todo_client/utils/hex_color_extension.dart';
class TodoType {

  final int id;
  Color color;
  String description;
  bool hasUpdated = false;

  TodoType({required this.id, required this.color, required this.description});
  
  TodoType.copy(TodoType other)
      : id = other.id,
        color = Color(other.color.value), // crea un nuovo oggetto Color
        description = other.description;

  factory TodoType.fromJson(Map<String, dynamic> json) {
    return TodoType(
      id: json['id'],
      color: (json['color'] as String).toColor(),
      description: json['description'],
    );
  }

}

