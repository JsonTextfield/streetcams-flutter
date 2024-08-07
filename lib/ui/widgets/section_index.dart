import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

class SectionIndex extends StatefulWidget {
  final List<String> data;
  final void Function(int)? onIndexSelected;
  final int minIndexHeight;

  const SectionIndex({
    super.key,
    required this.data,
    this.onIndexSelected,
    this.minIndexHeight = 30,
  });

  @override
  State<StatefulWidget> createState() {
    return _SectionIndexState();
  }
}

class _SectionIndexState extends State<SectionIndex> {
  final GlobalKey key = GlobalKey();
  int _selectedIndex = -1;
  LinkedHashMap<String, int> _index = LinkedHashMap();

  LinkedHashMap<String, int> _createIndex() {
    String dataString = (widget.data..sort()).map((str) => str[0]).join();

    RegExp letters = RegExp('[A-ZÀ-Ö]');
    RegExp numbers = RegExp('[0-9]');
    RegExp special = RegExp('[^0-9A-ZÀ-Ö]');

    LinkedHashMap<String, int> result = LinkedHashMap();
    if (special.hasMatch(dataString)) {
      result['*'] = dataString.indexOf(special);
    }
    if (numbers.hasMatch(dataString)) {
      result['#'] = dataString.indexOf(numbers);
    }
    for (var character in dataString.characters) {
      if (letters.hasMatch(character)) {
        result[character] = dataString.indexOf(character);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('building section index');

    _index = _createIndex();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int minIndexHeight = widget.minIndexHeight;
        int sectionsToShow = max(constraints.maxHeight ~/ minIndexHeight, 1);
        int skip = max(_index.length ~/ sectionsToShow, 1);

        List<Widget> result = _index.entries
            .toList()
            .asMap()
            .entries
            .where((entry) => entry.key % skip == 0)
            .map((entry) => entry.value)
            .map((entry) {
          return SectionIndexItem(
            title: entry.key,
            selected: _selectedIndex == entry.value,
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GestureDetector(
            key: key,
            child: Column(children: result),
            onTapDown: (details) => _selectIndex(details.localPosition.dy),
            onTapUp: (details) => _resetSelectedIndex(),
            onVerticalDragUpdate: (details) =>
                _selectIndex(details.localPosition.dy),
            onVerticalDragEnd: (details) => _resetSelectedIndex(),
          ),
        );
      },
    );
  }

  void _resetSelectedIndex() {
    setState(() => _selectedIndex = -1);
  }

  void _selectIndex(double yPosition) {
    var box = key.currentContext?.findRenderObject() as RenderBox;
    var sectionIndexHeight = box.constraints.maxHeight;
    var positions = _index.values.toList();
    int listIndex = (yPosition / sectionIndexHeight * positions.length)
        .toInt()
        .clamp(0, positions.length - 1);

    if (positions[listIndex] != _selectedIndex) {
      setState(() {
        _selectedIndex = positions[listIndex];
        widget.onIndexSelected?.call(_selectedIndex);
      });
    }
  }
}

class SectionIndexItem extends StatelessWidget {
  final bool selected;
  final String title;
  final Color? accentColour;

  const SectionIndexItem({
    super.key,
    required this.selected,
    required this.title,
    this.accentColour,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: selected
                ? accentColour ?? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
      ),
    );
  }
}
