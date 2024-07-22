import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadImages();
  }

  Future<void> _requestPermissions() async {
    await Permission.photos.request();
    await Permission.storage.request();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = '${directory.path}/CameraAppImages';
    final myDir = Directory(dirPath);
    if (!await myDir.exists()) {
      await myDir.create(recursive: true);
    }
    final List<FileSystemEntity> entities = await myDir.list().toList();
    final List<File> files = entities.whereType<File>().toList();
    setState(() {
      _images = files;
    });
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = '${directory.path}/CameraAppImages';
      await Directory(dirPath).create(recursive: true);
      final fileName = basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('$dirPath/$fileName');
      setState(() {
        _images.add(savedImage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gallery',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(
                _images[index],
                fit: BoxFit.cover,
              ),
            );
          },
          itemCount: _images.length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _captureImage,
        child: Icon(Icons.camera_alt_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
