import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';

class TodoService {
  const TodoService();

  final String baseUrl = "http://localhost:5000/api/todo";
  Future<List<Todo>> getAll() async {
    Uri uri = Uri.parse("$baseUrl/getAll");
    var response = await http.get(uri);

    //print(response.body);

    if (response.statusCode >= 400) {
      throw Exception("Error on todo reading");
    } else {
      var body = jsonDecode(response.body);
      List<Todo> todos = [];
      for (var todo in body) {
        todos.add(
          Todo(
            description: todo["description"],
            id: todo["id"],
            urgent: todo["urgent"],
            type: TodoType(
              id: todo["todoType"],
              description: "",
              color: Colors.transparent,
            ),
          ),
        );
      }
      return todos;
    }
  }

  Future<Todo> addTodo(Todo todo) async {
    Uri uri = Uri.parse("$baseUrl/save");
    print(todo.toJson());
    var response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(todo.toJson()),
    );
    if (response.statusCode >= 400) {
      print(response.body);
      throw Exception("Error on todo saving");
    }
    var body = jsonDecode(response.body);
    return Todo(
      description: body["description"],
      id: body["id"],
      urgent: body["urgent"],
      type: TodoType(
        id: body["todoType"],
        description: "",
        color: Colors.transparent,
      ),
    );
  }

  Future<Todo> updateTodo(Todo updatedToDo) async {
    Uri uri = Uri.parse("$baseUrl/update");
    print(updatedToDo.toJson());
    var response = await http.put(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updatedToDo.toJson()),
    );
    if (response.statusCode >= 400) {
      print(response.body);
      throw Exception("Error on updating saving");
    }
    var body = jsonDecode(response.body);
    return Todo(
      description: body["description"],
      id: body["id"],
      urgent: body["urgent"],
      type: TodoType(
        id: body["todoType"],
        description: "",
        color: Colors.transparent,
      ),
    );
  }

  Future<void> deleteTodo(int todoToDeleteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete/${todoToDeleteId}'),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode >= 400) {
      print("responseb bdoy >400: ${response.body}");
      throw Exception("Errore nell'eliminazione del todo lato server");
    }
  }
}
