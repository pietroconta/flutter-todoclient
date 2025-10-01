import 'package:todo_client/models/todo_type.dart';

class Todo {
  final int id;
  final String description;
  final bool urgent;
  TodoType type;
  bool checked = false;
  Todo({
    required this.id,
    required this.description,
    required this.urgent,
    required this.type,
  });

  @override
  String toString() {
    return '''
┌───────────────────────────┐
│       TODO ITEM           │
├───────────────────────────┤
│ • Description : $description
│ • Urgency     : ${urgent ? "Urgent" : "Not Urgent"}
│ • Type        : ${type.description}
└───────────────────────────┘
''';
  }

  Object toJson() {
    return {
      "id": id,
      "description": description,
      "urgent": urgent,
      "todoType": type.id,
    };
  }
}
