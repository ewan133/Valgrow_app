import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/authpages/document_waiting.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_service.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';

class ImageSubmissionPage extends StatefulWidget {
  final String uid;

  const ImageSubmissionPage({super.key, required this.uid});

  @override
  _ImageSubmissionPageState createState() => _ImageSubmissionPageState();
}

class _ImageSubmissionPageState extends State<ImageSubmissionPage> {
  final databaseService = DatabaseService();
  File? _selectedImage;
  final _auth = AuthService();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  void _submitImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String imageName = _auth.getUserUid();

    try {
      String? imageUrl =
          await Provider.of<StorageService>(context, listen: false)
              .uploadImage(_selectedImage!, imageName, context);

      if (imageUrl != null) {
        await databaseService.updateUserDocument(widget.uid, imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Successfully Submitted!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DocumentVerificationPage()),
        );
      } else {
        throw Exception("Image upload failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating profile")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadService = Provider.of<StorageService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            const Text(
              "Upload a Document",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text(
              "Choose an image from your gallery or take a new photo.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFFAAAAAA)),
            ),
            const SizedBox(height: 20),

            // Image Preview
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              height: 300,
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.insert_drive_file, size: 80, color: Color(0xFFAAAAAA)),
                        SizedBox(height: 10),
                        Text("No Image Selected",
                            style: TextStyle(fontSize: 16, color: Color(0xFFAAAAAA))),
                      ],
                    ),
            ),
            const SizedBox(height: 20),

            // Buttons for Image Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.image, color: Colors.white, size: 30,),
                  label: const Text("Gallery", style: TextStyle(color: Colors.white),),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14AE5C),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera, color: Colors.black, size: 30,),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(179, 255, 255, 255),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Submit Button
            _isUploading || uploadService.isUploading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF14AE5C)))
                : ElevatedButton(
                    onPressed: _submitImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14AE5C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit Image",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
