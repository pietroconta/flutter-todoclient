import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo_response.dart';
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/models/todo_type_response.dart';
import 'package:todo_client/providers/todo_type_provider.dart';
import 'package:todo_client/widget/type_card.dart';

class EditTodoType extends ConsumerStatefulWidget {
  EditTodoType({super.key});

  @override
  ConsumerState<EditTodoType> createState() => _EditTodoTypeState();
}

class _EditTodoTypeState extends ConsumerState<EditTodoType> {
  late Map<int, TodoType> originalTypeList; // Mappa originale
  Map<int, TodoType>? workingTypeMap; // Copia di lavoro
  bool _hasSaved = false;
  ScrollController scrollController = ScrollController();
  late TodoTypeResponse state;

  @override
  void initState() {
    super.initState();

    state = ref.read(todoTypeProvider);
    updateWorkingMap();
  }

  void updateWorkingMap() {
    originalTypeList = ref.read(todoTypeProvider).todoTypeMap;
    if(workingTypeMap != null) {
      print("\n\n____________________________\nOriginal type list: $originalTypeList\nWorking type map before: $workingTypeMap");
    }
    workingTypeMap = {
      for (var entry in originalTypeList.entries)
        entry.key: TodoType.copy(entry.value),
    };

    if(workingTypeMap != null) {
      print("Working type map after: $workingTypeMap\n\n__________________________\n\n");
    }

  }

  void updateType(TodoType toUpdate, GlobalKey<FormState> key) async {
    if (key.currentState!.validate()) {
      key.currentState!.save();
      Uri uri = Uri.http("localhost:5000", "api/type/update");
      var hex = '#${toUpdate.color.value.toRadixString(16)}';
      var requestBody = jsonEncode({
        'id': toUpdate.id,
        'description': toUpdate.description,
        'color': hex,
      });
      var response = await http.put(
        uri,
        body: requestBody,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 400) {
        return;
      } else if (response.statusCode == 200) {
        _hasSaved = true;
        toUpdate.hasUpdated = true;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully saved"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void shwDltDialog(TodoType toDelete) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Are you sure?"),
          content: Text(
            "Deleting Todo Type you will delete also the linked Todo",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                //delete
                await ref
                    .read(todoTypeProvider.notifier)
                    .deleteType(toDelete.id);
                bool deleted = ref.read(todoTypeProvider).errorMessage.isEmpty;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      deleted
                          ? "Deleted successfully"
                          : "Error during type elimination",
                    ),
                    duration: Duration(milliseconds: 1500),
                  ),
                );
                if (deleted) {
                  setState(() {
                    updateWorkingMap();
                  });
                }
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(_hasSaved);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          state.isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: workingTypeMap!.keys.length,
                    itemBuilder: (context, index) {
                      TodoType currentType =
                          workingTypeMap![workingTypeMap!.keys.toList()[index]]!;
                      return TypeCard(
                        type: currentType,
                        onSave: currentType.id == 0
                            ? (GlobalKey<FormState> key) async {
                                //addnew
                                if (key.currentState!.validate()) {
                                  key.currentState!.save();
                                  await ref
                                      .read(todoTypeProvider.notifier)
                                      .addNewType(currentType);

                                  if (ref
                                      .read(todoTypeProvider)
                                      .errorMessage
                                      .isEmpty) {
                                    setState(() {
                                      updateWorkingMap();
                                    });
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Successfully created"),
                                        duration: Duration(milliseconds: 1500),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error on creating new tipe",
                                        ),
                                        duration: Duration(milliseconds: 1500),
                                      ),
                                    );
                                  }
                                }
                              }
                            : (GlobalKey<FormState> key) {
                                //update
                                if (key.currentState!.validate()) {
                                  key.currentState!.save();
                                  ref
                                      .read(todoTypeProvider.notifier)
                                      .updateType(currentType);

                                  if (ref
                                      .read(todoTypeProvider)
                                      .errorMessage
                                      .isEmpty) {
                                    updateWorkingMap();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Successfully updated"),
                                        duration: Duration(milliseconds: 1500),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Error on updating new tipe",
                                        ),
                                        duration: Duration(milliseconds: 1500),
                                      ),
                                    );
                                  }
                                }
                              },
                        onDelete: shwDltDialog,
                      );
                    },
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  var keys = workingTypeMap!.keys.toList();
                  var newKey = keys.isEmpty
                      ? 1
                      : keys.reduce((a, b) => a > b ? a : b) + 1;
                  while (keys.contains(newKey)) {
                    newKey++;
                  }

                  workingTypeMap![newKey] = TodoType(
                    id: 0,
                    color: Colors.red,
                    description: "",
                  );
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                  );
                });
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
