import 'package:flutter_riverpod/legacy.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/models/todo_type_response.dart';
import 'package:todo_client/providers/services_provider.dart';
import 'package:todo_client/services/todo_type_service.dart';

class TodoTypeNotifier extends StateNotifier<TodoTypeResponse> {
  late TodoTypeService service;
  TodoTypeNotifier(this.service) : super(TodoTypeResponse()) {
    getAllType();
  }

  void getAllType() async {
    try {
      flushErrorMessage();
      state = state.copyWith(isLoading: true);
      List<TodoType> typeList = await service.getAll();
      Map<int, TodoType> typeMap = {};
      for (TodoType type in typeList) {
        typeMap[type.id] = type;
      }

      state = state.copyWith(todoTypeMap: typeMap);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteType(int id) async {
    try {
      flushErrorMessage();
      state = state.copyWith(isLoading: true);
      await service.deleteType(id);
      Map<int, TodoType> copyTypeMap = Map.from(state.todoTypeMap);
      copyTypeMap.removeWhere((k, v) => v.id == id);
      state = state.copyWith(todoTypeMap: copyTypeMap);
    } catch (e) {
      state = state.copyWith(errorMessage: "$e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addNewType(TodoType newType) async {
    try {
      flushErrorMessage();
      TodoType newTodoType = await service.addType(newType);
      Map<int, TodoType> copyTypeMap = Map.from(state.todoTypeMap);
      copyTypeMap.addAll({newTodoType.id: newTodoType});
      state = state.copyWith(todoTypeMap: copyTypeMap);
    } catch (e) {
      state = state.copyWith(errorMessage: "$e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateType(TodoType updatedType) async {
    try{
      flushErrorMessage();
      TodoType updatedTodoType = await service.updateType(updatedType);
      Map<int, TodoType> copyTypeMap = Map.from(state.todoTypeMap);
      copyTypeMap[updatedTodoType.id] = updatedTodoType;
      state = state.copyWith(todoTypeMap: copyTypeMap); 
    }catch(e){
      state = state.copyWith(errorMessage: "$e");
    }finally{
      state = state.copyWith(isLoading: false);
    }
  }

  void flushErrorMessage(){
    state = state.copyWith(errorMessage: null);
  }


}

final todoTypeProvider =
    StateNotifierProvider<TodoTypeNotifier, TodoTypeResponse>((ref) {
      return TodoTypeNotifier(ref.read(todoTypeServicesProvider));
    });
