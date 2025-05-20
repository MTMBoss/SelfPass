import 'package:flutter/material.dart';

List<TextSpan> highlightOccurrences(String text, String query) {
  if (query.isEmpty) {
    return [TextSpan(text: text)];
  }

  final List<TextSpan> spans = [];
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  int start = 0;
  int index = lowerText.indexOf(lowerQuery);

  while (index != -1) {
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }
    spans.add(
      TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(backgroundColor: Colors.yellow),
      ),
    );
    start = index + query.length;
    index = lowerText.indexOf(lowerQuery, start);
  }
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }
  return spans;
}
