import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoPicker extends StatefulWidget {
  final Function(File) onImagePicked;
  final String? initialImage;

  const ProfilePhotoPicker({
    super.key,
    required this.onImagePicked,
    this.initialImage,
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.initialImage != null) {
      _image = File(widget.initialImage!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
      widget.onImagePicked(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Camera'),
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: 50,
        backgroundImage: _image != null ? FileImage(_image!) : null,
        child: _image == null ? const Icon(Icons.add_a_photo, size: 50) : null,
      ),
    );
  }
}
