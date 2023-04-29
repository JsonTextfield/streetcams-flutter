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
  GlobalKey key = GlobalKey();
  int _selectedIndex = -1;
  final List<int> _positions = [];

  @override
  Widget build(BuildContext context) {
    debugPrint('building section index');
    List<Widget> result = [];
    Set<String> indices = {};
    String letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String numbers = '0123456789';
    for (int i = 0; i < widget.data.length; i++) {
      var firstChar = widget.data[i][0];

      if (numbers.contains(firstChar) && !indices.contains('#')) {
        indices.add('#');
        if (!_positions.contains(i)) {
          _positions.add(i);
        }
        result.add(SectionIndexItem(title: '#', selected: _selectedIndex == i));
      } else if (letters.contains(firstChar.toUpperCase()) &&
          !indices.contains(firstChar)) {
        indices.add(firstChar);
        if (!_positions.contains(i)) {
          _positions.add(i);
        }
        result.add(
          SectionIndexItem(title: firstChar, selected: _selectedIndex == i),
        );
      } else if (!numbers.contains(firstChar) &&
          !letters.contains(firstChar.toUpperCase()) &&
          !indices.contains('*')) {
        indices.add('*');
        if (!_positions.contains(i)) {
          _positions.add(i);
        }
        result.add(SectionIndexItem(title: '*', selected: _selectedIndex == i));
      }
    }

    return GestureDetector(
      key: key,
      child: Column(children: result),
      onTapDown: (details) => _selectIndexFromPointer(details.localPosition.dy),
      onTapUp: (details) => _resetSelectedIndex(),
      onVerticalDragUpdate: (details) =>
          _selectIndexFromPointer(details.localPosition.dy),
      onVerticalDragEnd: (details) => _resetSelectedIndex(),
    );
  }

  void _resetSelectedIndex() {
    setState(() => _selectedIndex = -1);
  }

  void _selectIndexFromPointer(double yPosition) {
    var box = key.currentContext?.findRenderObject() as RenderBox;
    var sectionIndexHeight = box.constraints.maxHeight;
    int listIndex = (yPosition / sectionIndexHeight * _positions.length)
        .toInt()
        .clamp(0, _positions.length - 1);

    if (_positions[listIndex] != _selectedIndex) {
      setState(() {
        _selectedIndex = _positions[listIndex];
        widget.callback(_selectedIndex);
      });
    }
  }
}

class SectionIndexItem extends StatelessWidget {
  final bool selected;
  final String title;

  const SectionIndexItem({
    super.key,
    required this.selected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: selected ? Constants.accentColour : null,
          ),
        ),
      ),
    );
  }
}
