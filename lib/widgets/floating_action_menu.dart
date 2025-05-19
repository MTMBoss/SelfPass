import 'package:flutter/material.dart';
import 'floating_menu.dart';

class FloatingActionMenu extends StatefulWidget {
  const FloatingActionMenu({super.key});

  @override
  FloatingActionMenuState createState() => FloatingActionMenuState();
}

class FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isMenuOpen)
          FloatingMenu(
            animation: _animationController,
            toggleMenu: _toggleMenu,
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleMenu,
            backgroundColor: Colors.blue,
            shape: const CircleBorder(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return RotationTransition(
                  turns:
                      child.key == const ValueKey('icon1')
                          ? Tween<double>(
                            begin: 0.75,
                            end: 1.0,
                          ).animate(animation)
                          : Tween<double>(
                            begin: 1.0,
                            end: 0.75,
                          ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child:
                  _isMenuOpen
                      ? const Icon(
                        Icons.close,
                        key: ValueKey('icon2'),
                        color: Colors.white,
                        size: 28,
                      )
                      : const Icon(
                        Icons.add,
                        key: ValueKey('icon1'),
                        color: Colors.white,
                        size: 28,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
