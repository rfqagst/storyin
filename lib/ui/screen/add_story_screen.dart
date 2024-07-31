import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:storyin/provider/story_provider.dart';
import 'package:storyin/utils/post_state.dart';

class AddStoryScreen extends StatefulWidget {
  final Function() onStoryUploaded;
  final Function() isPickLocation;
  const AddStoryScreen(
      {super.key, required this.onStoryUploaded, required this.isPickLocation});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  File? _image;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _resultText = '';
  Color _resultColor = Colors.black;

  StoryProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = context.read<StoryProvider>();

    _provider!.addListener(_onProviderStateChanged);

    setState(() {
      _resultText = '';
      _resultColor = Colors.black;
    });
  }

  void _onProviderStateChanged() {
    final provider = _provider;

    if (provider == null || !mounted) return;

    if (provider.postState == PostState.success) {
      setState(() {
        _resultText = provider.message;
        _resultColor = Colors.green;
      });
    } else if (provider.postState == PostState.error) {
      setState(() {
        _resultText = provider.message;
        _resultColor = Colors.red;
      });
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderStateChanged);
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Story"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            GestureDetector(
              onTap: () {
                _onGalleryView();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                width: double.infinity,
                height: 400,
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, color: Colors.grey, size: 50),
                          SizedBox(height: 20),
                          Text(
                            "Upload image from gallery",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 400,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 30),
            TextField(
              readOnly: true,
              controller: _locationController,
              decoration: InputDecoration(
                labelText: "Pick Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map),
                  color: const Color(0xFF10439F),
                  onPressed: () {
                    widget.isPickLocation();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _resultText,
              style: TextStyle(fontSize: 16, color: _resultColor),
            ),
            const SizedBox(height: 20),
            Consumer<StoryProvider>(builder: (context, provider, child) {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF10439F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    _uploadStory(provider);
                  },
                  child: provider.postState == PostState.loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "Upload",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
              );
            }),
          ]),
        ),
      ),
    );
  }

  _onGalleryView() async {
    final provider = context.read<StoryProvider>();
    final ImagePicker picker = ImagePicker();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Future<void> _uploadStory(StoryProvider provider) async {
    if (_image != null) {
      await provider.postStory(
        description: _descriptionController.text,
        photo: _image!,
      );
    }
    if (provider.postState == PostState.success) {
      widget.onStoryUploaded();
    }
  }
}
