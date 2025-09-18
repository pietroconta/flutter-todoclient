import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/screen/add_todo.dart';
import 'package:todo_client/screen/upt_todo.dart';
import 'package:todo_client/widget/countdown_bar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late Future<List<Todo>> futureTodos; // Future stabile
  List<Todo> todos = []; // Lista aggiornata dai dati del Future

  bool isChecked = false; // Variabile per il checkbox

  Map<int, TodoType> typeMap = {}; // Map per i tipi

  bool isDisabled = false;
  @override
  void initState() {
    super.initState();
    futureTodos = fetchData(); // Creo il future solo una volta
  }

  void disableCheckbox() {
    setState(() {
      isDisabled = true;
    });
  }

  bool isColorDark(Color c) {
    return c.computeLuminance() < 0.5;
  }

  Future<Todo?> navigateTo<T>(Widget dest) {
    return Navigator.push<Todo>(
      context,
      MaterialPageRoute(builder: (ctx) => dest),
    );
  }

  List<String> todoType = [];
  Future<List<Todo>> fetchData() async {
    // 1. Prendo tutti i tipi
    final typeResponse = await http.get(
      Uri.parse('http://localhost:5000/api/type/getall'),
    );

    if (typeResponse.statusCode != 200) {
      throw Exception('Errore nel caricamento dei tipi');
    }

    final List<dynamic> typeData = jsonDecode(typeResponse.body);

    typeMap = {
      for (var t in typeData)
        (t['id'] as int): TodoType.fromJson(t as Map<String, dynamic>),
    };

    // 2. Prendo tutti i Todo
    final todoResponse = await http.get(
      Uri.parse('http://localhost:5000/api/todo/getall'),
    );
    if (todoResponse.statusCode != 200) {
      throw Exception('Errore nel caricamento dei todo');
    }

    final List<dynamic> todoData = jsonDecode(todoResponse.body);

    // 3. Costruisco i Todo sostituendo l’id del tipo con l’oggetto TodoType
    todos = todoData.map((t) {
      final todoMap = t as Map<String, dynamic>;
      return Todo(
        id: todoMap['id'] as int,
        description: todoMap['description'] as String,
        urgent: todoMap['urgent'] as bool,
        type: typeMap[todoMap['todoType']]!,
      );
    }).toList();

    todos.sort((a, b) {
      return a.type.id.compareTo(b.type.id);
    }); // Ordino i todo per il tipo

    return todos;
  }

  void deleteToDo() async {
    Todo todoToDelete = todos.firstWhere((todo) => todo.checked);
    try {
      final typeResponse = await http.delete(
        Uri.parse('http://localhost:5000/api/todo/delete/${todoToDelete.id}'),
        headers: {"Content-Type": "application/json"},
      );

      if (typeResponse.statusCode == 200) {
        print(
          "Todo: ID: ${todoToDelete.id} \n Description: ${todoToDelete.description}\n Urgent: ${todoToDelete.urgent}\n è stato eliminato con successo!",
        );
      } else if (typeResponse.statusCode >= 400) {
        print("Errore nell'eliminazione del todo lato server");
      }
    } catch (e) {
      print("Errore nell'eliminazione del todo lato client: ${e.toString()}");
    }
    setState(() {
      isDisabled = false;
      isChecked = false;
      todos.remove(todoToDelete);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do List"),
        iconTheme: IconThemeData(size: 40),
        actions: [
          IconButton(
            onPressed: () async {
              final Todo? newToDo = await navigateTo(
                AddTodo(typeList: typeMap),
              );
              if (newToDo != null) {
                setState(() {
                  todos.add(newToDo);
                });
              }
            },
            icon: Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your To Do List:"),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Todo>>(
                future: futureTodos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("C'è stato un errore: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Nessun TODO! Aggiungine uno!");
                  } else {
                    final todos = snapshot.data!;
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Colors.grey[200], // colore del container generale
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: todos.map((todo) {
                            return InkWell(
                              onTap: (){
                                navigateTo(UptTodo(typeList: typeMap, todoToUpt: todo));
                              },
                              child: Container(
                                width: double.infinity,
                                key: ValueKey(todo.id),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: todo.type.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: todo.checked,
                                          onChanged: (value) {
                                            setState(() {
                                              if (!todo.checked && !isDisabled) {
                                                // Checkbox era false, ora diventa true → avvia countdown
                                                todo.checked = true;
                                                isChecked = true;
                                                disableCheckbox(); 
                                              } else {
                                                // Checkbox era true, ora diventa false → blocca countdown
                                                todo.checked = false;
                                                isChecked = false;
                                                isDisabled = false;
                                              }
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            todo.description,
                                            style: TextStyle(
                                              color: isColorDark(todo.type.color)
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            CountdownBar(
              isOn: isChecked,
              onStart: disableCheckbox,
              onFinished: deleteToDo,
            ),
          ],
        ),
      ),
    );
  }
}
