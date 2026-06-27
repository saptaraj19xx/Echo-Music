import 'package:flutter/material.dart';

/// Search page placeholder showing that search is being worked on.
/// This page should be replaced once the search feature is fully available.
class SearchPagePlaceholder extends StatelessWidget {
  const SearchPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Search coming soon!'),
      ),
    );
  }
}