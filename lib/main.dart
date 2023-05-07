import 'package:flutter/material.dart';
import 'package:sqlite_crud/models/contact.dart';
import 'package:sqlite_crud/utils/database_helper.dart';

const darkBlueColor = Color.fromARGB(255, 31, 51, 64);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Crud',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: darkBlueColor,
      ),
      home: const MyHomePage(title: 'SQLite Crud'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int id = 1;

  Contact _contact = Contact();
  List<Contact> _contacts = [];
  late DatabaseHelper _dbHelper;
  final _formKey = GlobalKey<FormState>();
  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });

    _refeshContactList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(color: darkBlueColor),
        )),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  _form() => Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _ctrlName,
              decoration: InputDecoration(labelText: 'Full Name'),
              onSaved: (val) => setState(() => _contact.name = val!),
              validator: (val) =>
                  (val!.isEmpty ? 'The field is required' : null),
            ),
            TextFormField(
              controller: _ctrlMobile,
              decoration: InputDecoration(labelText: 'Mobile'),
              onSaved: (val) => setState(() => _contact.mobile = val!),
              validator: (val) =>
                  (val!.length < 10 ? 'Atleast 10 characters required' : null),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => _onSubmit(),
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ));

  _refeshContactList() async {
    List<Contact> x = await _dbHelper.fetchContact();
    setState(() {
      _contacts = x;
    });
  }

  _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_contact.id == null)
        await _dbHelper.insertContact(_contact);
      else
        await _dbHelper.updateContact(_contact);
      _refeshContactList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState!.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
        child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          child: ListView.builder(
            padding: EdgeInsets.all(8),
            itemBuilder: (context, index) {
              return Column(children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    color: darkBlueColor,
                    size: 40,
                  ),
                  title: Text(
                    _contacts[index].name!.toUpperCase(),
                    style: TextStyle(
                        color: darkBlueColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_contacts[index].mobile!),
                  trailing: IconButton(
                      icon: Icon(Icons.delete_sweep, color: Colors.red),
                      onPressed: () async {
                        await _dbHelper.deleteContact(_contacts[index].id!);
                        _refeshContactList();
                      }),
                  onTap: () {
                    setState(() {
                      _contact = _contacts[index];
                      _ctrlName.text = _contacts[index].name!;
                      _ctrlMobile.text = _contacts[index].mobile!;
                    });
                  },
                ),
                Divider(
                  height: 5.0,
                )
              ]);
            },
            itemCount: _contacts.length,
          ),
        ),
      );
}
