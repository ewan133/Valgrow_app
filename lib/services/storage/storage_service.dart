import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService with ChangeNotifier {
  final firebaseStorage = FirebaseStorage.instance;

  List<String> _imageUrls = [];
  bool _isLoading = false;
  bool _isUploading = false;
  List<String> get imageUrls => _imageUrls;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  Future<void> fetchImages() async {
    _isLoading = true;
    notifyListeners(); // Notify UI before fetching

    try {
      final ListResult result =
          await firebaseStorage.ref('uploaded_images/').listAll();
      final urls =
          await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

      // ✅ Print each URL
      for (int i = 0; i < urls.length; i++) {
        print("Image $i: ${urls[i]}");
      }

      _imageUrls = urls;
    } catch (e) {
      print("❌ Error fetching images: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      imageUrls.remove(imageUrl);
      final String path = extractPathFromUrl(imageUrl);
      await firebaseStorage.ref(path).delete();
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);
    String encodedPath = uri.pathSegments.last;
    return Uri.decodeComponent(encodedPath);
  }

  Future<String?> uploadImage(
      File imageFile, String name, BuildContext context) async {
    _isUploading = true;
    notifyListeners();

    try {
      // Ensure the file has a proper extension
      String fileExtension = imageFile.path.split('.').last;
      if (fileExtension.isEmpty) {
        throw Exception("Invalid file format");
      }

      final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

      // Generate a unique file name using timestamp
      String filePath =
          'uploaded_images/${name}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      // Upload file to Firebase Storage
      TaskSnapshot uploadTask =
          await firebaseStorage.ref(filePath).putFile(imageFile);

      // Get download URL
      String downloadUrl = await uploadTask.ref.getDownloadURL();

      // ✅ Ensure the widget is still mounted before showing snackbar
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("✅ Image uploaded successfully!")),
        // );
      }

      print("✅ Upload successful: $downloadUrl"); // Debugging log

      return downloadUrl; // Return the image URL
    } catch (e) {
      print("❌ Upload error: $e");

      // ✅ Ensure the widget is still mounted before showing snackbar
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text("❌ Image upload failed: $e")),
        // );
      }

      return null; // Return null if upload fails
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
