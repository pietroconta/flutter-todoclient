import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/providers/todo_provider.dart';
import 'package:todo_client/providers/todo_type_provider.dart';

class UptTodo extends ConsumerStatefulWidget {
  UptTodo({super.key, required this.todoToUpt});

  final Todo todoToUpt;
  
  @override
  ConsumerState<UptTodo> createState() => _UptTodoState();
}

class _UptTodoState extends ConsumerState<UptTodo> {
  late TextEditingController _descriptionController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TodoType _selectedType;
  late Map<int, TodoType> typeMap;
  final List<DropdownMenuItem<TodoType>> _items = [];
  late bool _isUrgentField;
  @override
  void initState() {
    typeMap = ref.read(todoTypeProvider).todoTypeMap;
    _selectedType = widget.todoToUpt.type;
    _isUrgentField = widget.todoToUpt.urgent;
    setDropDownItems();

    

    _descriptionController = TextEditingController(
      text: widget.todoToUpt.description,
    );

    super.initState();
  }

  void sumbitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Todo? updatedTodo = Todo(id: widget.todoToUpt.id, description: _descriptionController.text, urgent: _isUrgentField, type: _selectedType);
      ref.read(todoProvider.notifier).updateTodo(updatedTodo);
      if(ref.read(todoProvider).errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error on updating todo"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
      // Chiudo la pagina passando il Todo aggiornato indietro
      Navigator.pop(context);
    }
  }

  void setDropDownItems() {
    List<int> keys = typeMap.keys.toList();
    for (int key in keys) {
      var item = DropdownMenuItem<TodoType>(
        value: typeMap[key],
        child: Text(typeMap[key]!.description),
      );

      _items.add(item);
    }

    _selectedType = widget.todoToUpt.type;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Todo')),
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
                        if (value!.isEmpty)
                          return "La descrizione non può essere vuota";
                      },
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    /*DropdownButton<String>(
                      value: _selectedValue, // può essere null
                      hint: const Text("Seleziona un tipo"),
                      items: widget.typeList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                      },
                    ),*/
                    //DropdownButton<TodoType>(items: widget.typeList, onChanged: onChanged)
                    DropdownButtonFormField<TodoType>(
                      items: _items,
                      value: _selectedType,
                      validator: (value) {
                        if (value!.id == 0) {
                          return "Seleziona almeno un valore!";
                        } else {
                          return null;
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text("Urgente "),
                        Checkbox(
                          value: _isUrgentField,
                          onChanged: (value) {
                            setState(() {
                              _isUrgentField = !_isUrgentField;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: sumbitForm,
                      child: Text("Aggiorna"),
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
