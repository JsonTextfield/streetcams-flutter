import 'package:flutter/material.dart';

import '../constants.dart';

class SectionIndex extends StatefulWidget {
  final List<String> data;
  final void Function(int) callback;

  const SectionIndex({super.key, required this.data, required this.callback});

  @override
  State<StatefulWidget> createState() {
    return _SectionIndexState();
  }
}

class _SectionIndexState extends State<SectionIndex> {
  int _selectedIndex = -1;
  final List<int> _positions = [];

  @override
  Widget build(BuildContext context) {
    debugPrint('building section index');
    List<Widget> result = [];
    Set<String> indices = {};

    for (int i = 0; i < widget.data.length; i++) {
      var firstLetter = widget.data[i][0];

      if (!indices.contains(firstLetter)) {
        indices.add(firstLetter);
        if (!_positions.contains(i)) {
          _positions.add(i);
        }
        result.add(
          Expanded(
            child: Container(
              color: Colors.transparent,
              width: 20,
              child: Center(
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedIndex == i ? Constants.accentColour : null,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return GestureDetector(
      child: Column(children: result),
      onTapDown: (details) =>
          _selectIndexFromPointer(details.globalPosition.dy),
      onTapUp: (details) => _resetSelectedIndex(),
      onVerticalDragUpdate: (details) =>
          _selectIndexFromPointer(details.globalPosition.dy),
      onVerticalDragEnd: (details) => _resetSelectedIndex(),
    );
  }

  void _resetSelectedIndex() {
    setState(() => _selectedIndex = -1);
  }

  void _selectIndexFromPointer(double yPosition) {
    var mediaQuery = MediaQuery.of(context);
    var topSection = mediaQuery.padding.top + AppBar().preferredSize.height;
    var yPos = yPosition - topSection;
    var sectionIndexHeight = mediaQuery.size.height - topSection;
    int listIndex = (yPos / sectionIndexHeight * _positions.length).toInt();

    if (_positions[listIndex] != _selectedIndex) {
      setState(() {
        _selectedIndex = _positions[listIndex];
        widget.callback(_selectedIndex);
      });
    }
  }
}