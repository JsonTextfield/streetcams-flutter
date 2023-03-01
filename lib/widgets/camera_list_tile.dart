import 'package:flutter/material.dart';

import '../constants.dart';
import '../entities/camera.dart';

class CameraListTile extends StatefulWidget {
  final Camera camera;
  final void Function() onLongPress;
  final void Function() onTap;
  final void Function(bool) onFavouriteTapped;
  final void Function(bool) onDismissed;

  const CameraListTile({
    super.key,
    required this.camera,
    required this.onLongPress,
    required this.onTap,
    required this.onFavouriteTapped,
    required this.onDismissed,
  });

  @override
  State<StatefulWidget> createState() => _CameraListTileState();
}

class _CameraListTileState extends State<CameraListTile> {
  bool _isSelected = false;
  bool _isFavourite = false;
  @override
  Widget build(BuildContext context) {
    _isFavourite = widget.camera.isFavourite;
    return Dismissible(
      key: Key(widget.camera.sortableName),
      child: ListTile(
        selected: _isSelected,
        selectedTileColor: Constants.accentColour,
        selectedColor: Colors.white,
        dense: true,
        title: Text(widget.camera.name, style: const TextStyle(fontSize: 16)),
        subtitle: Text(widget.camera.neighbourhood),
        trailing: IconButton(
          icon: Icon(_isFavourite ? Icons.star : Icons.star_border),
          color: _isFavourite ? Colors.yellow : null,
          onPressed: _favouriteTapped,
        ),
        onTap: _tapped,
        onLongPress: _longPressed,
      ),
      onDismissed: (direction) => widget.onDismissed,
    );
  }

  void _tapped() {
    if (_isSelected) {
      setState(() {
        _isSelected = !_isSelected;
      });
    }
    widget.onTap.call();
  }

  void _longPressed() {
    setState(() {
      _isSelected = !_isSelected;
    });
    widget.onLongPress.call();
  }

  void _favouriteTapped() {
    setState(() {
      _isFavourite = !_isFavourite;
    });
    widget.onFavouriteTapped.call(_isFavourite);
  }
}
