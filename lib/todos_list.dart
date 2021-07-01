import 'package:flutter/material.dart';
import 'todos_page.dart';
import './models/Todo.dart';
import 'todo_item.dart';

class TodosList extends StatelessWidget {
  final List<Todo> todos;

  TodosList({this.todos});

  @override
  Widget build(BuildContext context) {
    return todos.length >= 1
        ? ListView(
            padding: EdgeInsets.all(8),
            children: todos.map((todo) => TodoItem(todo: todo)).toList())
        : Center(child: Text('Tap button below to add a todo!'));
  }
}
