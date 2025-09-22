import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_client/models/todo_type.dart';
import 'package:todo_client/widget/type_card.dart';

class EditTodoType extends StatefulWidget {
  EditTodoType({super.key, required this.typeList});
  Map<int, TodoType> typeList;
  @override
  State<EditTodoType> createState() => _EditTodoTypeState();
}

class _EditTodoTypeState extends State<EditTodoType> {
  bool _hasSaved = false;
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
            content: Text("Succesfully saved"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  void addNewType(TodoType newType, GlobalKey<FormState> key) async {
    if (key.currentState!.validate()) {
      key.currentState!.save();
      Uri uri = Uri.http("localhost:5000", "api/type/add");
      var hex = '#${newType.color.value.toRadixString(16)}';
      var requestBody = jsonEncode({
        'id': newType.id,
        'description': newType.description,
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
        newType.hasUpdated = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Succesfully saved"),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    _hasSaved = false;
    print(widget.typeList.keys);
    super.initState();
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
              itemCount: widget.typeList.keys.length,
              itemBuilder: (context, index) {
                TodoType currentType =
                    widget.typeList[widget.typeList.keys.toList()[index]]!;
                return TypeCard(type: currentType, onSave: currentType.id == 0 ? addNewType : updateType);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {           
                  widget.typeList[0] = TodoType(
                    id: 0,
                    color: Colors.red,
                    description: "",
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
