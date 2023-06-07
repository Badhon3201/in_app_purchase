import 'package:custom_dropdown_widget/radio_validation.dart';
import 'package:custom_dropdown_widget/validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'animation/view/splash_view.dart';
import 'checkbox_icon_formfield.dart';
import 'checkbox_list_tile_formfield.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashView(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    bool? checkboxIconFormFieldValue = false;
    final scaffoldKey = GlobalKey<FormState>();

    const List<String> list = <String>[
      'One dfds sdfsd sdfsd sdvdsv sdfvsdf sdvdsv sdfdsaf ',
      'Two',
      'Three',
      'Four'
    ];
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: scaffoldKey,
            child: Column(
              children: [
                RadioListTileFormField(),
                RadioListTileFormField(),
                CheckboxListTileFormField(
                  title: const Text('Check!'),
                  onSaved: (bool? value) {
                    print(value);
                  },
                  validator: (bool? value) {
                    if (value!) {
                      return null;
                    } else {
                      return 'False!';
                    }
                  },
                  onChanged: (value) {
                    if (value) {
                      if (kDebugMode) {
                        print("ListTile Checked :)");
                      }
                    } else {
                      if (kDebugMode) {
                        print("ListTile Not Checked :(");
                      }
                    }
                  },
                  autovalidateMode: AutovalidateMode.always,
                  contentPadding: const EdgeInsets.all(1),
                ),
                CheckboxIconFormField(
                  context: context,
                  initialValue: checkboxIconFormFieldValue,
                  enabled: true,
                  iconSize: 32,
                  onSaved: (bool? value) {
                    checkboxIconFormFieldValue = value;
                  },
                  onChanged: (value) {
                    if (value) {
                      print("Icon Checked :)");
                    } else {
                      print("Icon Not Checked :(");
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(hintText: "Input"),
                  validator: (v) => Validator.validateNid(v!),
                ),
                TextButton(
                  onPressed: () {
                    if (scaffoldKey.currentState!.validate()) {
                      print("aaaaaaaaaaaaaaaaaaaa");
                    }
                  },
                  child: const Text("Submit"),
                )
              ],
            ),
          ),
        ));
  }
}
