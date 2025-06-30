import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

typedef OnImageSelected = void Function(XFile? image);
typedef OnFileSelected = void Function(PlatformFile? file);

class AggiungiImmagineButton extends StatefulWidget {
  final OnImageSelected onImageSelected;

  const AggiungiImmagineButton({super.key, required this.onImageSelected});

  @override
  State<AggiungiImmagineButton> createState() => _AggiungiImmagineButtonState();
}

class _AggiungiImmagineButtonState extends State<AggiungiImmagineButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      widget.onImageSelected(image);
    } catch (e) {
      // Handle errors if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Aggiungi immagine'),
      onPressed: _pickImage,
    );
  }
}

class AggiungiFileButton extends StatefulWidget {
  final OnFileSelected onFileSelected;

  const AggiungiFileButton({super.key, required this.onFileSelected});

  @override
  State<AggiungiFileButton> createState() => _AggiungiFileButtonState();
}

class _AggiungiFileButtonState extends State<AggiungiFileButton> {
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        widget.onFileSelected(result.files.first);
      } else {
        widget.onFileSelected(null);
      }
    } catch (e) {
      // Handle errors if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.attach_file),
      label: const Text('Aggiungi file'),
      onPressed: _pickFile,
    );
  }
}
