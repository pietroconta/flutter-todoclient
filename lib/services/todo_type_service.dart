import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';

class TodoTypeService {
  const TodoTypeService();

  final String baseUrl = "http://localhost:5000/api/type";
  Future<List<TodoType>> getAll() async {
    Uri uri = Uri.parse("$baseUrl/getAll");
    var response = await http.get(uri);

    if (response.statusCode >= 400) {
      throw Exception("Error on todo reading");
    } else {
      var body = jsonDecode(response.body);
      List<TodoType> types = [];
      for (var type in body) {
        types.add(
         TodoType.fromJson(type)
        );
      }
      return types;
    }
  }

  Future<void> deleteType(int id) async {
    Uri uri = Uri.parse("$baseUrl/delete/$id");
    var response = await http.delete(uri, headers: {"Content-Type": "application/json"});
    if (response.statusCode >= 400) {
      throw Exception("Error on todo type deleting");
    }

  }

  Future<TodoType> addType(TodoType newType) async {
    Uri uri = Uri.parse("$baseUrl/save");
    var response = await http.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(newType.toJson()));
    if (response.statusCode >= 400) {
      throw Exception("Error on todo type adding");
    }
    return TodoType.fromJson(jsonDecode(response.body));

  }

  Future<TodoType> updateType(TodoType updatedType) async{
    Uri uri = Uri.parse("$baseUrl/update");
    var response = await http.put(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(updatedType.toJson()));
    if (response.statusCode >= 400) {
      throw Exception("Error on todo type updating");
    }
    return TodoType.fromJson(jsonDecode(response.body));
  }
 }
