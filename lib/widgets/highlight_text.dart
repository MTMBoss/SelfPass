import 'package:flutter/material.dart';

class _Match {
  final int start;
  final int end;
  _Match(this.start, this.end);
}

class HighlightText extends StatelessWidget {
  final String source;
  final String query;
  final TextStyle style;
  final Color? highlightColor;

  const HighlightText({
    super.key,
    required this.source,
    required this.query,
    required this.style,
    this.highlightColor,
  });

  TextSpan _highlightOccurrences(
    String source,
    String query,
    TextStyle style,
    Color highlightColor,
  ) {
    if (query.isEmpty) {
      return TextSpan(text: source, style: style);
    }
    final matches = <_Match>[];
    final queryLower = query.toLowerCase();
    final sourceLower = source.toLowerCase();
    int start = 0;
    while (true) {
      final index = sourceLower.indexOf(queryLower, start);
      if (index == -1) break;
      matches.add(_Match(index, index + query.length));
      start = index + query.length;
    }
    if (matches.isEmpty) {
      return TextSpan(text: source, style: style);
    }
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;
    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: source.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: style.copyWith(backgroundColor: highlightColor),
        ),
      );
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < source.length) {
      spans.add(TextSpan(text: source.substring(lastMatchEnd), style: style));
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveHighlightColor =
        highlightColor ?? Theme.of(context).colorScheme.secondary.withAlpha(77);
    return RichText(
      text: _highlightOccurrences(
        source,
        query,
        style,
        effectiveHighlightColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
