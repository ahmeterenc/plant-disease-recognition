import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  XFile? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _uploadImage(pickedFile);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage(XFile file) async {
    try {
      var uri = Uri.parse('http://192.168.137.159:5000/predict');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', file.path));


      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseData.body);

        if (jsonResponse['success']) {
          String prediction = jsonResponse['prediction'];
          String recommendation = jsonResponse['recommendation'];

          print('Hastalık: $prediction');
          print('Tavsiye: $recommendation');

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Hastalık Sonucu'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text('Hastalık: $prediction'),
                      SizedBox(height: 10),
                      Text('Tavsiye:'),
                      Text(recommendation),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('Failed to get a successful response');
        }
      } else {
        print('Failed to upload: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _imageFile == null
            ? const Text('Henüz bir görsel seçilmedi.')
            : Image.file(File(_imageFile!.path)),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () =>_pickImage(ImageSource.gallery),
            tooltip: 'Galeriden Seç',
            child: const Icon(Icons.photo),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.camera),
            tooltip: 'Kamerayı Kullan',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
