import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_client/models/todo.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/providers/todo_provider.dart';
import 'package:todo_client/providers/todo_type_provider.dart';
import 'package:todo_client/providers/todotype_provider.dart';
import 'package:todo_client/screen/add_todo.dart';
import 'package:todo_client/screen/edit_todo_type.dart';
import 'package:todo_client/screen/upt_todo.dart';
import 'package:todo_client/widget/countdown_bar.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  late Future<List<Todo>> futureTodos;

  // late TodoTypeResponse typeMapResponse;
  // late TodoResponse todoResponse;

  bool isChecked = false; // Variabile per il checkbox

  Map<int, Todo> todoMap = {};
  Map<int, TodoType> typeMap = {};

  bool isDisabled = false;
  @override
  void initState() {
    super.initState();
    //futureTodos = fetchData(); // Creo il future solo una volta
  }

  void disableCheckbox() {
    setState(() {
      isDisabled = true;
    });
  }

  bool isContained(TodoType type) {
    for (var t in typeMap.entries) {
      if (t.value.id == type.id) {
        return true;
      }
    }
    return false;
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

  Future<bool?> navToEditTypes<T>(typeList) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => EditTodoType()),
    );
  }

  @override
  Widget build(BuildContext context) {
    //subscribe al provider di todotyperesponse
    //con il watch ogni volta che cambia lo stato viene triggerato il build di nuovo

    final typeMapResponse = ref.watch(todoTypeProvider);
    final todoResponse = ref.watch(todoTypeCombProvider);

    typeMap = typeMapResponse.todoTypeMap;

    todoMap = todoResponse.todoMap;
    /*print("typemap: ${typeMap.length}");
    print("todotype: ${todoMap.length}");*/
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do List"),
        iconTheme: IconThemeData(size: 40),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () {
                  navigateTo(AddTodo(typeList: typeMap));
                },
                child: Text("Add To Do"),
              ),

              PopupMenuItem(
                onTap: () {
                  navToEditTypes(typeMap);
                },
                child: Text("Edit To Do types"),
              ),
            ],
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
              child: ListView.builder(
                itemCount: todoMap.length,
                itemBuilder: (context, index) {
                  final todo = todoMap.values.elementAt(index);
                  return InkWell(
                    onTap: () {
                      navigateTo(UptTodo(todoToUpt: todo));
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
                              if (todo.urgent) Icon(Icons.warning),
                              Checkbox(
                                value: todo.checked,
                                onChanged: (value) {
                                  setState(() {
                                    if (!todo.checked && !isDisabled) {
                                      todo.checked = true;
                                      isChecked = true;
                                      disableCheckbox();
                                    } else if (todo.checked) {
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
                },
              ),
            ),
            CountdownBar(
              isOn: isChecked,
              onStart: disableCheckbox,
              onFinished: () {
                Todo todoToDelete = todoMap.entries
                    .firstWhere((todo) => todo.value.checked)
                    .value;

                ref.read(todoProvider.notifier).deleteTodo(todoToDelete.id);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ref.read(todoProvider).errorMessage.isEmpty ? "Todo deleted successfully" : "Error during todo elimination",),
                    duration: Duration(milliseconds: 1500),
                  ),
                );

                setState(() {
                  isDisabled = false;
                  isChecked = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
