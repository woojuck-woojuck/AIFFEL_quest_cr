import 'package:flutter/material.dart';

class GalleryResultScreen extends StatelessWidget {
  const GalleryResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery Results')),
      body: const Center(
        child: Text('Gallery of saved results will be shown here.'),
      ),
    );
  }
}