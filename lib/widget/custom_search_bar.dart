import 'dart:async';

import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  const CustomSearchBar({super.key, required this.onSearch});

  @override
  State<CustomSearchBar> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<CustomSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearch(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}