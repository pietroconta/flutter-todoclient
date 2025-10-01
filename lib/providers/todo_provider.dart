import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_response.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/providers/services_provider.dart';
import 'package:todo_client/providers/todo_type_provider.dart';
import 'package:todo_client/services/todo_service.dart';

class TodoNotifier extends StateNotifier<TodoResponse> {
  final TodoService todoService;

  TodoNotifier(this.todoService) : super(TodoResponse()) {
    getAllTodo();
  }

  void getAllTodo() async {
    try {
      state = state.copyWith(isLoading: true);

      // Aspetta che i tipi siano caricati
      // Poi recupera i todo
      List<Todo> todoList = await todoService.getAll();
      Map<int, Todo> todoMap = {};

      for (Todo todo in todoList) {
        // Associa il tipo completo al todo

        todoMap[todo.id] = todo;
        //print("-- Todo: ${todo.id} - ${todo.description} - Tipo: ${todo.type.id}");
      }

      state = state.copyWith(todoMap: todoMap);
    } catch (e) {
      print("Errore in getAllTodo: $e");
      state = state.copyWith(errorMessage: "$e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addTodo(Todo newTodo) async {
    try {
      state = state.copyWith(isLoading: true);
      Todo addedoTodo = await todoService.addTodo(newTodo);
      state = state.copyWith(
        todoMap: state.todoMap..addAll({addedoTodo.id: addedoTodo}),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: "$e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateTodo(Todo updatedTodo) async {
    try {
      state = state.copyWith(isLoading: true);
      updatedTodo = await todoService.updateTodo(updatedTodo);
      state = state.copyWith(
        todoMap: state.todoMap..addAll({updatedTodo.id: updatedTodo}),
      );
    } catch(e) {
      state = state.copyWith(errorMessage: "$e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

    Future<void> deleteTodo(int id) async {
    try{
      state = state.copyWith(isLoading: true);
      await todoService.deleteTodo(id);
    
      Map<int, Todo> updatedMap = Map.from(state.todoMap);
      updatedMap.removeWhere((k, v) => v.id == id);
      
      state = state.copyWith(todoMap: updatedMap);
    }catch(e){
      state = state.copyWith(errorMessage: "$e");
    }finally{
      state = state.copyWith(isLoading: false);
    }
  }

  void flushErrorMessage() {
    state = state.copyWith(errorMessage: null);
  }

  
}

final todoProvider = StateNotifierProvider<TodoNotifier, TodoResponse>(
  (ref) => TodoNotifier(
    ref.read(todoServicesProvider), // = TodoService()
  ),
);
