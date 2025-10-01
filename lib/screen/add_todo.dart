import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/providers/todo_provider.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/providers/todo_provider.dart';

class AddTodo extends ConsumerStatefulWidget {
  const AddTodo({super.key, required this.typeList});
  final Map<int, TodoType> typeList;

  @override
  ConsumerState<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends ConsumerState<AddTodo> {
  final List<DropdownMenuItem<TodoType>> _items = [];
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  TodoType? _selectedType;
  bool _isUrgentField = false;

  // Placeholder
  final TodoType placeholder = TodoType(id: 0, description: "Seleziona un tipo", color: Colors.transparent);

  void setDropDownItems() {
    _items.clear();

    // aggiungo subito il placeholder
    _items.add(DropdownMenuItem<TodoType>(
      value: placeholder,
      child: Text(placeholder.description),
    ));

    widget.typeList.forEach((key, type) {
      _items.add(DropdownMenuItem<TodoType>(
        value: type,
        child: Text(type.description),
      ));
    });

    _selectedType = placeholder; // valore iniziale
  }

  @override
  void initState() {
    setDropDownItems();
    super.initState();
  }

  void sumbitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Todo newToDo = Todo(
        id: 0,
        description: _descriptionController.text,
        urgent: _isUrgentField,
        type: _selectedType!,
      );
      print(newToDo.toString());
      ref.read(todoProvider.notifier).addTodo(newToDo);
      if (ref.read(todoProvider).errorMessage.isNotEmpty) {
        print(" Error new: ${ref.read(todoProvider).errorMessage}");
      }
      ref.read(todoProvider.notifier).flushErrorMessage();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Todo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "La descrizione non può essere vuota";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<TodoType>(
                      value: _selectedType,
                      items: _items,
                      validator: (value) {
                        if (value == null || value.id == 0) {
                          return "Seleziona almeno un valore!";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Tipo",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Urgente "),
                        Checkbox(
                          value: _isUrgentField,
                          onChanged: (value) {
                            setState(() {
                              _isUrgentField = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: sumbitForm,
                      child: Text("Aggiungi"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
