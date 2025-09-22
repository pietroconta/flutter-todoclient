import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:todo_client/models/todo_type.dart';

class TypeCard extends StatefulWidget {
  TypeCard({super.key, required this.type, required this.onSave});
  TodoType type;
  Function onSave;
  @override
  State<TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<TypeCard> {

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  
  void changeColor(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Select a color"),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MaterialPicker(
            pickerColor: widget.type.color, onColorChanged: (color){
            setState(() {
              widget.type.color = color;
            });
          }),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("Chiudi"))
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value){
                  setState(() {
                    widget.type.description = value!;

                  });
                },
                initialValue:  widget.type.description,
                decoration: const InputDecoration(
                  label: Text("Description"),
                  isDense: true, // compatto
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: changeColor,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 0.3)),
                  child: SizedBox(height: 35, width: 90, child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                       
                        SizedBox(width: 30,
                        height: 30,
                        child: Container(
                          color: widget.type.color,
                        ),),
                        SizedBox(width: 10,),
                         Text("Label "),
                      ],
                    ),
                  ),),
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                widget.onSave(widget.type, _formKey);
              }, child: Text("Salva"))
            ],
          ),
        ),
      ),
   
    );
  }
}
