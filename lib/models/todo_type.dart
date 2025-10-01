import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TodoType {

  int id;
  Color color = Colors.transparent;
  String description = "";
  bool hasUpdated = false;

  TodoType({required this.id, required this.color, required this.description});
  
  TodoType.copy(TodoType other)
      : id = other.id,
        color = Color(other.color!.value), // crea un nuovo oggetto Color
        description = other.description;

  factory TodoType.fromJson(Map<String, dynamic> json) {
    return TodoType(
      id: json['id'],
      color: (json['color'] as String).toColor()!,
      description: json['description'],
    );
  }

  Object toJson(){
    return {
      'id': id,
      'color': color.toHexString(),
      'description': description,
    };
  }

}

