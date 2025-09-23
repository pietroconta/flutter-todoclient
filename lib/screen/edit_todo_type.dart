import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/widget/type_card.dart';

class EditTodoType extends StatefulWidget {
  EditTodoType({super.key, required this.originalTypeList});
  Map<int, TodoType> originalTypeList; // Mappa originale
  @override
  State<EditTodoType> createState() => _EditTodoTypeState();
}

class _EditTodoTypeState extends State<EditTodoType> {
  late Map<int, TodoType> workingTypeList; // Copia di lavoro
  bool _hasSaved = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Creo la copia di lavoro all'inizializzazione
    workingTypeList = {
      for (var entry in widget.originalTypeList.entries)
        entry.key: TodoType.copy(entry.value),
    };
    print(workingTypeList.keys);
  }

  void _updateOriginalMap() {
    // Aggiorna la mappa originale con i valori della copia di lavoro
    for (var entry in workingTypeList.entries) {
      if (widget.originalTypeList.containsKey(entry.key)) {
        // Aggiorna tipo esistente
        widget.originalTypeList[entry.key]!.color = entry.value.color;
        widget.originalTypeList[entry.key]!.description = entry.value.description;
        widget.originalTypeList[entry.key]!.hasUpdated = false;
      } else {
        // Aggiungi nuovo tipo (solo se ha un ID valido dal server)
        if (entry.value.id != 0) {
          widget.originalTypeList[entry.key] = TodoType.copy(entry.value);
          widget.originalTypeList[entry.key]!.hasUpdated = false;
        }
      }
    }
    
    // Rimuovi i tipi che sono stati eliminati dalla copia di lavoro
    var keysToRemove = <int>[];
    for (var key in widget.originalTypeList.keys) {
      if (!workingTypeList.containsKey(key)) {
        keysToRemove.add(key);
      }
    }
    for (var key in keysToRemove) {
      widget.originalTypeList.remove(key);
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
        
        // Aggiorna immediatamente la mappa originale
        _updateOriginalMap();
        
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                deleteType(toDelete);
              },
              child: Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  void deleteType(TodoType toDelete) async {
    Uri uri = Uri.http("localhost:5000", "/api/type/delete/${toDelete.id}");
    var response = await http.delete(uri);

    bool success = false;
    if (response.statusCode == 200) {
      success = true;
      // Rimuovi l'elemento dalla copia di lavoro
      setState(() {
        workingTypeList.removeWhere((key, value) => value.id == toDelete.id);
      });
      
      
      // Aggiorna immediatamente la mappa originale
      _updateOriginalMap();
      _hasSaved = true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? "Deleted successfully" : "Error during type elimination",
        ),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void addNewType(TodoType newType, GlobalKey<FormState> key) async {
    if (key.currentState!.validate()) {
      key.currentState!.save();
      Uri uri = Uri.http("localhost:5000", "api/type/save");
      var hex = '#${newType.color.value.toRadixString(16)}';
      var requestBody = jsonEncode({
        'description': newType.description,
        'color': hex,
      });
      var response = await http.post(
        uri,
        body: requestBody,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 400) {
        return;
      } else if (response.statusCode == 200) {
        var responseId = jsonDecode(response.body)["id"];
        newType.id = responseId;
        _hasSaved = true;
        newType.hasUpdated = true;
        
        // Aggiorna la chiave nella mappa di lavoro con il nuovo ID
        setState(() {
          var oldKey = workingTypeList.keys.firstWhere((key) => 
              workingTypeList[key] == newType);
          workingTypeList.remove(oldKey);
          workingTypeList[responseId] = newType;
        });
        
        // Aggiorna immediatamente la mappa originale
        _updateOriginalMap();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully created"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
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
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: workingTypeList.keys.length,
              itemBuilder: (context, index) {
                TodoType currentType =
                    workingTypeList[workingTypeList.keys.toList()[index]]!;
                return TypeCard(
                  type: currentType,
                  onSave: currentType.id == 0 ? addNewType : updateType,
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
                  var keys = workingTypeList.keys.toList();
                  var newKey = keys.isEmpty ? 1 : keys.reduce((a, b) => a > b ? a : b) + 1;
                  while (keys.contains(newKey)) {
                    newKey++;
                  }

                  workingTypeList[newKey] = TodoType(
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