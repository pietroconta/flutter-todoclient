import 'package:todo_client/models/todo.dart';

class TodoResponse {
  TodoResponse();
 
  bool isLoading = false;
  String errorMessage = "";
  Map<int, Todo> todoMap = {};
 
  TodoResponse copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<int, Todo>? todoMap,
  }) {
    TodoResponse nuovo = TodoResponse();
    nuovo.isLoading = isLoading ?? this.isLoading;
    // Per errorMessage, permettiamo di impostarlo a stringa vuota
    nuovo.errorMessage = errorMessage ?? this.errorMessage;
    // CRUCIALE: crea sempre una NUOVA mappa per evitare condivisione di riferimenti
    nuovo.todoMap = todoMap != null ? Map.from(todoMap) : Map.from(this.todoMap);
 
    return nuovo;
  }
}
