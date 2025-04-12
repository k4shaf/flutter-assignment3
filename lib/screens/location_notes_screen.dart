import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../db/database_helper.dart';

class LocationNotesScreen extends StatefulWidget {
  const LocationNotesScreen({super.key});

  @override
  State<LocationNotesScreen> createState() => _LocationNotesScreenState();
}

class _LocationNotesScreenState extends State<LocationNotesScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final db = await DatabaseHelper.instance.database;
    final locations = await db.query('locations');
    setState(() {
      _locations = locations;
    });
  }

  Future<void> _addLocation() async {
    if (_nameController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      final db = await DatabaseHelper.instance.database;
      await db.insert('locations', {
        'userId': 1,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'picture': null,
      });
      _nameController.clear();
      _descriptionController.clear();
      _fetchLocations();
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteLocation(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
    _fetchLocations();
  }

  Future<void> _updatePicture(int id) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final db = await DatabaseHelper.instance.database;
      await DatabaseHelper.instance.updatePicture(id, pickedFile.path);
      _fetchLocations();
    }
  }

  Future<void> _deletePicture(int id) async {
    await DatabaseHelper.instance.deletePicture(id);
    _fetchLocations();
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addLocation,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Notes')),
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final location = _locations[index];
          return ListTile(
            title: Text(location['name']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location['description']),
                if (location['picture'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(
                      File(location['picture']),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _updatePicture(location['id']),
                ),
                if (location['picture'] != null)
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: () => _deletePicture(location['id']),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteLocation(location['id']),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
