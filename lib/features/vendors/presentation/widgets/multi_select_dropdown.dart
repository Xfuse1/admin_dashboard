import 'package:flutter/material.dart';

/// A multi-select dropdown widget with checkboxes.
class MultiSelectDropdown<T> extends StatefulWidget {
  final String hint;
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final IconData Function(T)? itemIcon;
  final void Function(List<T>) onChanged;
  final double? width;
  final bool enabled;

  const MultiSelectDropdown({
    Key? key,
    required this.hint,
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    this.itemIcon,
    required this.onChanged,
    this.width,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  late List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  void didUpdateWidget(MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItems != widget.selectedItems) {
      _selectedItems = List.from(widget.selectedItems);
    }
  }

  void _toggleItem(T item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
    });
    widget.onChanged(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: PopupMenuButton<T>(
        enabled: widget.enabled,
        offset: const Offset(0, 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedItems.isEmpty
                      ? widget.hint
                      : '${widget.hint} (${_selectedItems.length})',
                  style: TextStyle(
                    color: _selectedItems.isEmpty
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withOpacity(0.7),
                size: 24,
              ),
            ],
          ),
        ),
        itemBuilder: (context) {
          return widget.items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return PopupMenuItem<T>(
              enabled: false, // Disable default close behavior
              padding: EdgeInsets.zero,
              child: StatefulBuilder(
                builder: (context, setMenuState) {
                  return CheckboxListTile(
                    value: isSelected,
                    title: Row(
                      children: [
                        if (widget.itemIcon != null) ...[
                          Icon(
                            widget.itemIcon!(item),
                            size: 18,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            widget.itemLabel(item),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? value) {
                      _toggleItem(item);
                      setMenuState(() {});
                    },
                  );
                },
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
