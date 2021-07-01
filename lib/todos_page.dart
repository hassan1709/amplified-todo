// @dart=2.9
// dart async library we will refer to when setting up real time updates
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'models/ModelProvider.dart';
import 'models/Todo.dart';
import 'todos_list.dart';
import 'add_todo_form.dart';

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  // for tracking loading ui state
  bool _isLoading;

  // list of Todos
  List<Todo> _todos;

  // amplify plugins
  final AmplifyDataStore _dataStorePlugin =
      AmplifyDataStore(modelProvider: ModelProvider.instance);

  // subscription to Todo model update events
  StreamSubscription _subscription;

  @override
  void initState() {
    // initialize loading ui state to a loading state
    _isLoading = true;

    // initialize Todos list as an empty list
    _todos = [];

    // kick off app initialization
    _initializeApp();

    super.initState();
  }

  @override
  void dispose() {
    // cancel the subscription when the state is removed from the tree
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // configure Amplify
    await _configureAmplify();

    // listen for updates to Todo entries by passing the Todo classType to
    // Amplify.DataStore.observe() and when an update event occurs, fetch the
    // todo list
    //
    // note this strategy may not scale well with larger number of entries
    _subscription = Amplify.DataStore.observe(Todo.classType).listen((event) {
      _fetchTodos();
    });

    // fetch Todo entries from DataStore
    await _fetchTodos();

    // after configuring Amplify, update loading ui state to loaded state
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _configureAmplify() async {
    try {
      // add Amplify plugins
      await Amplify.addPlugins([_dataStorePlugin]);

      // configure Amplify
      //
      // note that Amplify cannot be configured more than once!
      await Amplify.configure(amplifyconfig);
    } catch (e) {
      // error handling can be improved for sure!
      // but this will be sufficient for the purposes of this tutorial
      print('An error occurred while configuring Amplify: $e');
    }
  }

  Future<void> _fetchTodos() async {
    try {
      // query for all Todo entries by passing the Todo classType to
      // Amplify.DataStore.query()
      List<Todo> updatedTodos = await Amplify.DataStore.query(Todo.classType);

      // update the ui state to reflect fetched todos
      setState(() {
        _todos = updatedTodos;
      });
    } catch (e) {
      print('An error occurred while querying Todos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Todo List'),
      ),
      //body: Center(child: CircularProgressIndicator()),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TodosList(todos: _todos),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTodoForm()),
          );
        },
        tooltip: 'Add Todo',
        label: Row(
          children: [Icon(Icons.add), Text('Add todo')],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
