import 'package:todo_client/models/todo_type.dart';

class TodoTypeResponse {
  TodoTypeResponse();
  bool isLoading = false;


  String errorMessage = "";
  Map<int, TodoType> todoTypeMap = {};

  TodoTypeResponse copyWith({bool? isLoading,
  String? errorMessage, Map<int, TodoType>? todoTypeMap}){
    TodoTypeResponse newTR = TodoTypeResponse();
    newTR.isLoading = isLoading ?? this.isLoading;
    newTR.errorMessage = errorMessage ?? this.errorMessage;
    newTR.todoTypeMap = todoTypeMap ?? this.todoTypeMap;


    return newTR;
  }
}