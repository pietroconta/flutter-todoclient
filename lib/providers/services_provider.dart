import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_client/services/todo_service.dart';
import 'package:todo_client/services/todo_type_service.dart';

final todoServicesProvider = Provider<TodoService>((ref)=> TodoService());
final todoTypeServicesProvider = Provider<TodoTypeService>((ref)=> TodoTypeService());