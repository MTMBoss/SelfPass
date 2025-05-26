import 'package:flutter/material.dart';
import '../../../services/icon_service.dart';
import '../../../widgets/symbol_families_selector.dart';

class IconSelector extends StatelessWidget {
  final String iconSelectionMode;
  final String websiteUrl;
  final IconData? selectedSymbolIcon;
  final Color? selectedSymbolColor;
  final Color? selectedColorIcon;
  final Function(String) onModeSelected;
  final Function(IconData, Color?) onSymbolSelected;
  final Function(Color) onColorSelected;

  const IconSelector({
    super.key,
    required this.iconSelectionMode,
    required this.websiteUrl,
    this.selectedSymbolIcon,
    this.selectedSymbolColor,
    this.selectedColorIcon,
    required this.onModeSelected,
    required this.onSymbolSelected,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (mode) {
        onModeSelected(mode);
        if (mode == 'Symbol') {
          _showSymbolSelectionDialog(context);
        } else if (mode == 'Color') {
          _showColorSelectionDialog(context);
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'Website Icon',
              child: Text('Website Icon'),
            ),
            const PopupMenuItem(value: 'Symbol', child: Text('Symbol')),
            const PopupMenuItem(value: 'Color', child: Text('Color')),
            const PopupMenuItem(
              value: 'Custom Icon',
              child: Text('Custom Icon'),
            ),
          ],
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.transparent,
        child: _buildIcon(),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconSelectionMode == 'Website Icon' && websiteUrl.isNotEmpty) {
      return _buildWebsiteFavicon();
    } else if (iconSelectionMode == 'Symbol' && selectedSymbolIcon != null) {
      return Icon(
        selectedSymbolIcon,
        color: selectedSymbolColor ?? Colors.black,
      );
    } else if (iconSelectionMode == 'Color' && selectedColorIcon != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: selectedColorIcon,
          shape: BoxShape.circle,
        ),
      );
    }
    return Icon(IconService.getIconForMode(iconSelectionMode));
  }

  Widget _buildWebsiteFavicon() {
    final faviconUrl = IconService.getFaviconUrl(websiteUrl);
    return ClipOval(
      child: Image.network(
        faviconUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(IconService.getIconForMode('Website Icon'));
        },
      ),
    );
  }

  void _showSymbolSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Symbol Icon'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: SymbolFamiliesSelector(
              onSymbolSelected: (iconData, color) {
                Navigator.of(context).pop();
                _showSymbolColorSelectionDialog(context, iconData);
              },
            ),
          ),
        );
      },
    );
  }

  void _showSymbolColorSelectionDialog(
    BuildContext context,
    IconData iconData,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Symbol Color'),
          content: _buildColorGrid(
            onColorSelected: (color) {
              onSymbolSelected(iconData, color);
              Navigator.of(context).pop();
            },
            selectedColor: selectedSymbolColor,
          ),
        );
      },
    );
  }

  void _showColorSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: _buildColorGrid(
            onColorSelected: (color) {
              onColorSelected(color);
              Navigator.of(context).pop();
            },
            selectedColor: selectedColorIcon,
          ),
        );
      },
    );
  }

  Widget _buildColorGrid({
    required Function(Color) onColorSelected,
    Color? selectedColor,
  }) {
    return SizedBox(
      width: double.maxFinite,
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        children:
            IconService.availableColors.map((color) {
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          selectedColor == color
                              ? Colors.black
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  width: 36,
                  height: 36,
                ),
              );
            }).toList(),
      ),
    );
  }
}
