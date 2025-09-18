import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({super.key, required this.typeList});
  final Map<int, TodoType> typeList;

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final List<DropdownMenuItem<TodoType>> _items = [];
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  TodoType? _selectedType;
  bool _isUrgentField = false;

  void setDropDownItems() {
    List<int> keys = widget.typeList.keys.toList();
    for (int key in keys) {
      var item = DropdownMenuItem<TodoType>(
        value: widget.typeList[key],
        child: Text(widget.typeList[key]!.description),
      );

      _items.add(item);
    }

    var initial = DropdownMenuItem<TodoType>(
      value: _selectedType,
      child: Text("Seleziona un tipo"),
    );
    

    _items.insert(0, initial);
  }

  @override
  void initState() {
    setDropDownItems();
    super.initState();
  }

  void sumbitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Todo? newToDo;

      try{
      final typeResponse = await http.post(
        Uri.parse('http://localhost:5000/api/todo/save'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "description": _descriptionController.text,
          "urgent": _isUrgentField,
          "todoType": _selectedType!.id,
        }),
      );

      if (typeResponse.statusCode == 200) {
        print("Todo aggiunto con successo");
        var body = jsonDecode(typeResponse.body);
        newToDo = Todo(id:  body["id"], description:  body["description"], urgent:  body["urgent"], type: _selectedType!);
        print(newToDo.toString());
      } else {
        print("Errore nell'aggiunta del todo");
      }

      }catch(e){
        print("Errore nell'aggiunta del todo");
      }


      Navigator.pop(context, newToDo);
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
                      validator: (value){
                        if(value!.isEmpty) return "La descrizione non può essere vuota";
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
