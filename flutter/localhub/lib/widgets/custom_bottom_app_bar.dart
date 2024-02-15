import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBarItem {
  IconData icon;
  CustomAppBarItem({required this.icon});
}

class CustomBottomAppBar extends StatefulWidget {
  const CustomBottomAppBar({
    super.key,
    required this.onTabSelected,
    required this.items,
  });
  final ValueChanged<int> onTabSelected;
  final List<CustomAppBarItem> items;

  @override
  State<CustomBottomAppBar> createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0;

  void updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(widget.items.length, (int index) {
      return _buildTabIcon(
          index: index,
          item: widget.items[index],
          onPressed: updateIndex,
          context: context);
    });
    items.insert(items.length >> 1, _buildMiddleSeperator());
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }

  Widget _buildTabIcon(
      {required int index,
      required CustomAppBarItem item,
      required ValueChanged<int> onPressed,
      required BuildContext context}) {
    return IconButton(
      onPressed: () => onPressed(index),
      icon: FaIcon(
        item.icon,
        color: _selectedIndex == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildMiddleSeperator() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 10,
        )
      ],
    );
  }
}

// Global key to access CustomBottomAppBarState from other files
final GlobalKey<_CustomBottomAppBarState> customBottomAppBarKey =
    GlobalKey<_CustomBottomAppBarState>();
