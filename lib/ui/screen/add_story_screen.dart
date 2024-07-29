import 'dart:io';

import 'package:flutter/material.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Story"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              width: double.infinity,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null
                      ? const Icon(Icons.add_a_photo,
                          color: Colors.grey, size: 50)
                      : Image.file(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                  const SizedBox(height: 20),
                  const Text(
                    "Upload image from gallery",
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
            ),
            const SizedBox(height: 60),
            TextField(
              minLines: 5,
              maxLines: 10,
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF10439F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {},
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
