import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_sizes.dart';

/// Search field pinned under the large title on the Medications tab.
/// Clear button appears only once there is text; clearing calls
/// [onChanged] with an empty string so the caller can return to the
/// cached, unfiltered list.
class SearchField extends StatefulWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    required this.hintText,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.searchH,
      child: TextField(
        controller: widget.controller,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hintText,
          prefixIcon: Icon(LucideIcons.search, size: AppSizes.iconSm),
          suffixIcon:
              widget.controller.text.isEmpty
                  ? null
                  : IconButton(
                    icon: const Icon(Icons.clear, size: AppSizes.iconSm),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                  ),
        ),
      ),
    );
  }
}
