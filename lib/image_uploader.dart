import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageUploadScreen extends StatefulWidget {
  final User user;

  const ImageUploadScreen({super.key, required this.user});

  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _image;
  int _likeCount = 0;
  int _commentCount = 0;
  int _shareCount = 0;
  final TextEditingController _commentController = TextEditingController();
  DocumentReference? _currentPostRef;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance.ref().child('uploads/$fileName').putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      DocumentReference postRef = await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': downloadUrl,
        'userId': widget.user.uid,
        'likeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _image = null;
        _currentPostRef = postRef;
        _likeCount = 0;
        _commentCount = 0;
        _shareCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }

  Future<void> _likePost() async {
    if (_currentPostRef != null) {
      await _currentPostRef!.update({'likeCount': FieldValue.increment(1)});
      setState(() {
        _likeCount++;
      });
    }
  }

  Future<void> _commentPost() async {
    if (_currentPostRef != null && _commentController.text.isNotEmpty) {
      await _currentPostRef!.update({'commentCount': FieldValue.increment(1)});
      await _currentPostRef!.collection('comments').add({
        'text': _commentController.text,
        'userId': widget.user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _commentCount++;
        _commentController.clear();
      });
    }
  }

  Future<void> _sharePost() async {
    if (_currentPostRef != null) {
      await _currentPostRef!.update({'shareCount': FieldValue.increment(1)});
      setState(() {
        _shareCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome, ${widget.user.displayName}'),
            const SizedBox(height: 20),
            _image == null ? const Text('No image selected.') : AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.file(
                _image!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Post Image'),
            ),
            const SizedBox(height: 20),
            if (_currentPostRef != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: _likePost,
                  ),
                  Text('$_likeCount'),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () => _showCommentDialog(context),
                  ),
                  Text('$_commentCount'),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _sharePost,
                  ),
                  Text('$_shareCount'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a Comment'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(hintText: 'Enter your comment here'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _commentPost();
              },
              child: const Text('Post Comment'),
            ),
          ],
        );
      },
    );
  }
}