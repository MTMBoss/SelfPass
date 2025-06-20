import 'package:flutter/material.dart';
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
  TitoloCampoState createState() => TitoloCampoState();
}

class TitoloCampoState extends State<TitoloCampo> {
  IconData? selectedIcon;
  Color? selectedColor;
  String? customSymbol;

  String? faviconUrl;
  ImageProvider? faviconImage;

  @override
  void initState() {
    super.initState();
    if (widget.sitoWebController != null) {
      widget.sitoWebController!.addListener(_updateFavicon);
      _updateFavicon();
    }
  }

  @override
  void dispose() {
    if (widget.sitoWebController != null) {
      widget.sitoWebController!.removeListener(_updateFavicon);
    }
    super.dispose();
  }

  void _updateFavicon() {
    final urlText = widget.sitoWebController!.text.trim();
    if (urlText.isEmpty) {
      setState(() {
        faviconUrl = null;
        faviconImage = null;
      });
      return;
    }
    Uri? uri;
    try {
      uri = Uri.parse(urlText);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlText');
      }
    } catch (e) {
      uri = null;
    }
    if (uri == null || uri.host.isEmpty) {
      setState(() {
        faviconUrl = null;
        faviconImage = null;
      });
      return;
    }
    final faviconUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/favicon.ico',
    );
    setState(() {
      faviconUrl = faviconUri.toString();
      faviconImage = NetworkImage(faviconUrl!);
    });
  }

  void _showOptionsMenu() async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset btnOrigin = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final Size btnSize = button.size;

    // offset verticale in più per non coprire l'icona
    const double yOffset = 8;

    // posizione a destra e leggermente sotto il pulsante
    final double left = btnOrigin.dx + btnSize.width;
    final double top = btnOrigin.dy + btnSize.height + yOffset;
    final double right = overlay.size.width - left;
    final double bottom = overlay.size.height - top;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, right, bottom),
      items: const [
        PopupMenuItem(value: 'website_icon', child: Text('Icona Sito Web')),
        PopupMenuItem(value: 'select_symbol', child: Text('Seleziona Simbolo')),
        PopupMenuItem(value: 'select_color', child: Text('Seleziona Colore')),
        PopupMenuItem(
          value: 'custom_icon',
          child: Text('Icona Personalizzata'),
        ),
      ],
    );

    if (selected == null) return;
    switch (selected) {
      case 'website_icon':
        setState(() {
          selectedIcon = null;
          selectedColor = null;
          customSymbol = null;
          // Show favicon if available
          if (faviconImage == null) {
            selectedIcon = Icons.language;
          }
        });
        break;
      case 'select_symbol':
        _selectSymbol();
        break;
      case 'select_color':
        _selectColor();
        break;
      case 'custom_icon':
        _customIconInput();
        break;
    }
  }

  Future<void> _selectSymbol() async {
    final symbol = await showDialog<String>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: const Text('Seleziona Simbolo'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '★'),
                child: const Text('★'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '✓'),
                child: const Text('✓'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '✗'),
                child: const Text('✗'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, '⚡'),
                child: const Text('⚡'),
              ),
            ],
          ),
    );
    if (symbol != null) {
      setState(() {
        customSymbol = symbol;
        selectedIcon = null;
        selectedColor = null;
      });
    }
  }

  Future<void> _selectColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder:
          (_) => SimpleDialog(
            title: const Text('Seleziona Colore'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, Colors.red),
                child: const Text('Rosso'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, Colors.green),
                child: const Text('Verde'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, Colors.blue),
                child: const Text('Blu'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, Colors.orange),
                child: const Text('Arancione'),
              ),
            ],
          ),
    );
    if (color != null) {
      setState(() {
        selectedColor = color;
        selectedIcon = null;
        customSymbol = null;
      });
    }
  }

  Future<void> _customIconInput() async {
    final textController = TextEditingController(text: customSymbol ?? '');
    final result = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Icona Personalizzata'),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: 'Inserisci simbolo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, textController.text),
                child: const Text('OK'),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        customSymbol = result;
        selectedIcon = null;
        selectedColor = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget;
    if (selectedIcon != null) {
      iconWidget = Icon(selectedIcon, color: selectedColor ?? Colors.black);
    } else if (customSymbol != null) {
      iconWidget = Text(
        customSymbol!,
        style: TextStyle(fontSize: 24, color: selectedColor ?? Colors.black),
      );
    } else if (faviconImage != null) {
      iconWidget = Image(
        image: faviconImage!,
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.language);
        },
      );
    } else {
      iconWidget = const Icon(Icons.image);
    }

    return Row(
      children: [
        Expanded(
          child: CampoTestoCustom(
            label: 'Titolo',
            controller: widget.controller,
            onRemove: widget.onRemove,
            obscureText: false,
          ),
        ),
        IconButton(
          icon: iconWidget,
          onPressed: _showOptionsMenu,
          tooltip: 'Opzioni Icona',
        ),
      ],
    );
  }
}
