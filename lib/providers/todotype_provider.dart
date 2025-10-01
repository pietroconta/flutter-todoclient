import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_response.dart';
import 'package:todo_client/providers/todo_provider.dart';
import 'package:todo_client/providers/todo_type_provider.dart';

// Provider derivato che combina todos e tipi
final todoTypeCombProvider = Provider<TodoResponse>((ref) {
  final todoResponse = ref.watch(todoProvider);
  final typeResponse = ref.watch(todoTypeProvider);
  
  // Se uno dei due sta caricando, restituisci lo stato di loading
  if (todoResponse.isLoading || typeResponse.isLoading) {
    return todoResponse.copyWith(isLoading: true);
  }
  
  // Se ci sono errori, propagali
  if (todoResponse.errorMessage.isNotEmpty) {
    return todoResponse;
  }
  if (typeResponse.errorMessage.isNotEmpty) {
    return todoResponse.copyWith(errorMessage: typeResponse.errorMessage);
  }

  //filtra i dati
 
  
  // Combina i dati
  Map<int, Todo> enhancedTodoMap = {};
  final typeMap = typeResponse.todoTypeMap;
  
  for (var entry in todoResponse.todoMap.entries) {
    final todo = entry.value;
    final completeType = typeMap[todo.type.id];
    
    if (completeType != null) {
      // Crea un nuovo todo con il tipo completo MANTENENDO lo stato checked
      final enhancedTodo = Todo(
        id: todo.id,
        description: todo.description,
        urgent: todo.urgent,
        type: completeType,
      );
      enhancedTodo.checked = todo.checked; // MANTIENI lo stato checked
      enhancedTodoMap[entry.key] = enhancedTodo;
    } else {
      // Mantieni il todo originale se il tipo non è trovato
      //enhancedTodoMap[entry.key] = todo;
    }
  }
  
  return todoResponse.copyWith(todoMap: enhancedTodoMap);
});