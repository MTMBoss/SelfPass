import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'campo_testo_custom.dart';

class TitoloCampo extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController? sitoWebController;
  final VoidCallback? onRemove;

  const TitoloCampo({
    super.key,
    required this.controller,
    this.sitoWebController,
    this.onRemove,
  });

  @override
  State<TitoloCampo> createState() => _TitoloCampoState();
}

class _TitoloCampoState extends State<TitoloCampo> {
  Color selectedColor = Colors.black;
  String? customSymbol;
  bool applyColorToEmoji = false;
  String _faviconUrl = '';
  Timer? _debounce;

  static const List<Color> _presetColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.grey,
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sitoWebController != null) {
      widget.sitoWebController!.addListener(_onUrlChanged);
      _onUrlChanged();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.sitoWebController != null) {
      widget.sitoWebController!.removeListener(_onUrlChanged);
    }
    super.dispose();
  }

  void _onUrlChanged() {
    // reset immediato di simbolo e colore
    setState(() {
      customSymbol = null;
      applyColorToEmoji = false;
      selectedColor = Colors.black;
    });

    // debounce favicon
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final text = widget.sitoWebController!.text.trim();
      if (text.contains('.') && text.length > 3) {
        Uri? uri = Uri.tryParse(text);
        if (uri != null && !uri.hasScheme) {
          uri = Uri.parse('https://$text');
        }
        if (uri?.host.isNotEmpty ?? false) {
          final url =
              Uri(
                scheme: uri!.scheme,
                host: uri.host,
                port: uri.hasPort ? uri.port : null,
                path: '/favicon.ico',
              ).toString();
          setState(() {
            _faviconUrl = url;
          });
          return;
        }
      }
      setState(() {
        _faviconUrl = '';
      });
    });
  }

  Future<void> _selectSymbol() async {
    const symbols = ['★', '✓', '✗', '⚡', '❤️', '🔥', '⭐'];
    final picked = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: const Text('Seleziona Simbolo'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      symbols.map((s) {
                        return GestureDetector(
                          onTap: () => Navigator.pop(context, s),
                          child: Text(s, style: const TextStyle(fontSize: 28)),
                        );
                      }).toList(),
                ),
              ),
            ],
          ),
    );
    if (!mounted || picked == null) return;

    customSymbol = picked;
    final apply = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Colorazione Emoji'),
            content: const Text(
              'Vuoi applicare il colore selezionato\n'
              'o mantenerne i colori originali?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Originali'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Applica colore'),
              ),
            ],
          ),
    );
    if (!mounted) return;

    applyColorToEmoji = apply ?? false;
    if (applyColorToEmoji) {
      final c = await _pickColor();
      if (mounted && c != null) {
        selectedColor = c;
      }
    }
    setState(() {});
  }

  Future<Color?> _pickColor() async {
    final result = await showDialog<dynamic>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Scegli un colore'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      _presetColors.map((col) {
                        return GestureDetector(
                          onTap: () => Navigator.pop(ctx, col),
                          child: CircleAvatar(backgroundColor: col, radius: 18),
                        );
                      }).toList(),
                ),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'custom'),
                child: const Text('Altri colori…'),
              ),
            ],
          ),
    );
    if (!mounted || result == null) return null;

    if (result == 'custom') {
      Color tmp = selectedColor;
      final picked = await showDialog<Color>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Altri colori'),
              content: BlockPicker(
                pickerColor: tmp,
                onColorChanged: (c) => tmp = c,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tmp),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return picked;
    }
    return result as Color;
  }

  Future<void> _onColorIconPressed() async {
    // reset simbolo, favicon e colore
    setState(() {
      customSymbol = null;
      applyColorToEmoji = false;
      _faviconUrl = '';
    });
    final c = await _pickColor();
    if (mounted && c != null) {
      setState(() => selectedColor = c);
    }
  }

  Future<void> _showOptionsMenu() async {
    final choice = await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: const [
        PopupMenuItem(value: 'website', child: Text('Icona Sito Web')),
        PopupMenuItem(value: 'symbol', child: Text('Emoji/Simbolo')),
        PopupMenuItem(value: 'color', child: Text('Colore icona')),
        PopupMenuItem(value: 'reset', child: Text('Reset')),
      ],
    );
    if (!mounted) return;

    switch (choice) {
      case 'website':
        setState(() {
          customSymbol = null;
          applyColorToEmoji = false;
          selectedColor = Colors.black;
          _faviconUrl = '';
        });
        break;
      case 'symbol':
        await _selectSymbol();
        return;
      case 'color':
        await _onColorIconPressed();
        return;
      case 'reset':
        setState(() {
          customSymbol = null;
          applyColorToEmoji = false;
          selectedColor = Colors.black;
          _faviconUrl = '';
        });
        break;
      default:
        return;
    }
  }

  Widget _buildIcon() {
    if (customSymbol != null) {
      if (applyColorToEmoji) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback:
              (bounds) => LinearGradient(
                colors: [selectedColor, selectedColor],
              ).createShader(bounds),
          child: Text(customSymbol!, style: const TextStyle(fontSize: 28)),
        );
      }
      return Text(customSymbol!, style: const TextStyle(fontSize: 28));
    }

    if (_faviconUrl.isNotEmpty) {
      return Image.network(
        _faviconUrl,
        width: 28,
        height: 28,
        loadingBuilder: (ctx, child, progress) {
          if (progress != null) {
            return const SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return child;
        },
        errorBuilder:
            (_, __, ___) => Icon(Icons.language, color: selectedColor),
      );
    }

    return CircleAvatar(radius: 14, backgroundColor: selectedColor);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CampoTestoCustom(
            label: 'Titolo',
            controller: widget.controller,
            onRemove: widget.onRemove,
          ),
        ),
        IconButton(
          icon: _buildIcon(),
          tooltip: 'Opzioni Icona',
          onPressed: _showOptionsMenu,
        ),
      ],
    );
  }
}
