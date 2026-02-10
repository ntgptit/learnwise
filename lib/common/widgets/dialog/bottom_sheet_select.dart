import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

class BottomSheetSelectOption<T> {
  const BottomSheetSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class BottomSheetSelect<T> extends StatelessWidget {
  const BottomSheetSelect({
    super.key,
    required this.options,
    required this.onSelected,
    this.title,
  });

  final List<BottomSheetSelectOption<T>> options;
  final ValueChanged<T> onSelected;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: AppSizes.size1),
          ],
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (BuildContext context, int index) {
                return const Divider(height: AppSizes.size1);
              },
              itemBuilder: (BuildContext context, int index) {
                final BottomSheetSelectOption<T> option = options[index];
                return ListTile(
                  title: Text(option.label),
                  onTap: () => onSelected(option.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
