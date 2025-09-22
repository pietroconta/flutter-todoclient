import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';

class UptTodo extends StatefulWidget {
  UptTodo({super.key, required this.typeList, required this.todoToUpt});

  final Todo todoToUpt;
  final Map<int, TodoType> typeList;
  @override
  State<UptTodo> createState() => _UptTodoState();
}

class _UptTodoState extends State<UptTodo> {
  late TextEditingController _descriptionController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TodoType _selectedType;
  final List<DropdownMenuItem<TodoType>> _items = [];
  late bool _isUrgentField;
  @override
  void initState() {
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
      Todo? updatedToDo;

      try {
        final response = await http.put(
          Uri.parse(
            'http://localhost:5000/api/todo/update/',
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "id": widget.todoToUpt.id,
            "description": _descriptionController.text,
            "urgent": _isUrgentField,
            "todoType": _selectedType.id,
          }),
        );

        if (response.statusCode == 200) {
          print("Todo aggiornato con successo");

          final body = jsonDecode(response.body);
          updatedToDo = Todo(
            id: body["id"],
            description: body["description"],
            urgent: body["urgent"],
            type: _selectedType,
          );

          print(updatedToDo.toString());
        } else {
          print("Errore nell'aggiornamento del todo: ${response.statusCode}");
        }
      } catch (e) {
        print("Errore nella richiesta di aggiornamento: $e");
      }

      // Chiudo la pagina passando il Todo aggiornato indietro
      Navigator.pop(context, updatedToDo);
    }
  }

  void setDropDownItems() {
    List<int> keys = widget.typeList.keys.toList();
    for (int key in keys) {
      var item = DropdownMenuItem<TodoType>(
        value: widget.typeList[key],
        child: Text(widget.typeList[key]!.description),
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
