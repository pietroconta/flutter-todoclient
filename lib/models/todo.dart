
import 'package:todo_client/models/todo_type.dart';
class Todo {
  final int id;
  final String description;
  final bool urgent;
  TodoType type;
  bool checked = false;
  Todo({required this.id, required this.description, required this.urgent, required this.type});

  @override
  String toString() {
    return 'Description: $description\n {this.urgent ? "Urgent" : "Not Urgent"}\n Type: ${type.description}';
  }
}

