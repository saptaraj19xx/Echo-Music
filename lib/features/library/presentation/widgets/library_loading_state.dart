import 'package:flutter/material.dart';

class LibraryLoadingState extends StatelessWidget {
  const LibraryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}