// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';

import '../../styles/app_sizes.dart';

/// Represents a single option in a [SelectBox] dropdown.
///
/// Each option has a [value] for the selected data and a [label]
/// for display. Options can be disabled and include an optional leading widget.
class SelectOption<T> {
  const SelectOption({
    required this.value,
    required this.label,
    this.enabled = true,
    this.leading,
  });

  /// The underlying value this option represents.
  final T value;

  /// The display label for this option.
  final String label;

  /// Whether this option can be selected. Defaults to true.
  final bool enabled;

  /// Optional widget to display before the label (e.g., an icon).
  final Widget? leading;
}

/// A form-integrated dropdown selection field.
///
/// This widget wraps [DropdownButtonFormField] with consistent styling
/// and validation support. It displays a list of [SelectOption]s and
/// allows the user to select one.
///
/// Migration note:
/// - This widget currently uses [DropdownButtonFormField] for compatibility.
/// - A future opt-in migration path to Material 3 [DropdownMenu] can provide
///   richer UX such as built-in filtering/search patterns.
///
/// The generic type [T] represents the type of value stored in each option.
///
/// Example:
/// ```dart
/// SelectBox<String>(
///   labelText: 'Country',
///   hintText: 'Select your country',
///   options: [
///     SelectOption(value: 'us', label: 'United States'),
///     SelectOption(value: 'uk', label: 'United Kingdom'),
///     SelectOption(value: 'ca', label: 'Canada'),
///   ],
///   value: selectedCountry,
///   onChanged: (value) => setState(() => selectedCountry = value),
/// )
/// ```
///
/// See also:
///  * [SelectOption], the option data class
///  * [TextBox], for text input with validation
class SelectBox<T> extends StatelessWidget {
  const SelectBox({
    required this.options,
    super.key,
    this.value,
    this.onChanged,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.useDropdownMenu = false,
    this.enableFilter = false,
    this.enableSearch = true,
  });

  /// The list of options to display in the dropdown.
  final List<SelectOption<T>> options;

  /// The currently selected value.
  final T? value;

  /// Called when the user selects a different option.
  final ValueChanged<T?>? onChanged;

  /// Label displayed above the dropdown.
  final String? labelText;

  /// Hint text displayed when no option is selected.
  final String? hintText;

  /// Helper text displayed below the dropdown to provide guidance.
  final String? helperText;

  /// Error text displayed below the dropdown when validation fails.
  final String? errorText;

  /// Whether the dropdown is enabled for interaction. Defaults to true.
  final bool enabled;

  /// Validator function for form validation.
  ///
  /// Returns an error message string if validation fails, or null if valid.
  final FormFieldValidator<T>? validator;

  /// Whether to use Material 3 [DropdownMenuFormField] instead of
  /// [DropdownButtonFormField].
  ///
  /// Defaults to false for backward compatibility.
  final bool useDropdownMenu;

  /// Whether [DropdownMenuFormField] should filter options while typing.
  ///
  /// Only applies when [useDropdownMenu] is true.
  final bool enableFilter;

  /// Whether [DropdownMenuFormField] should highlight search matches.
  ///
  /// Only applies when [useDropdownMenu] is true.
  final bool enableSearch;

  @override
  Widget build(BuildContext context) {
    if (useDropdownMenu) {
      return _buildDropdownMenuFormField(context);
    }

    return _buildLegacyDropdownFormField(context);
  }

  Widget _buildLegacyDropdownFormField(BuildContext context) {
    return Semantics(
      label: labelText,
      hint: hintText,
      enabled: enabled,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        items: options.map((option) {
          return DropdownMenuItem<T>(
            value: option.value,
            enabled: option.enabled,
            child: Row(
              children: <Widget>[
                if (option.leading != null) ...<Widget>[
                  option.leading!,
                  const SizedBox(width: AppSizes.spacingXs),
                ],
                Expanded(child: Text(option.label)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDropdownMenuFormField(BuildContext context) {
    return Semantics(
      label: labelText,
      hint: hintText,
      enabled: enabled,
      child: DropdownMenuFormField<T>(
        enabled: enabled,
        initialSelection: value,
        onSelected: onChanged,
        validator: validator,
        forceErrorText: errorText,
        label: _buildLabelWidget(),
        hintText: hintText,
        helperText: helperText,
        enableFilter: enableFilter,
        enableSearch: enableSearch,
        expandedInsets: EdgeInsets.zero,
        inputDecorationTheme: InputDecorationThemeData(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        dropdownMenuEntries: _buildDropdownMenuEntries(),
      ),
    );
  }

  Widget? _buildLabelWidget() {
    if (labelText == null) {
      return null;
    }
    return Text(labelText!);
  }

  List<DropdownMenuEntry<T>> _buildDropdownMenuEntries() {
    return options.map((option) {
      return DropdownMenuEntry<T>(
        value: option.value,
        label: option.label,
        leadingIcon: option.leading,
        enabled: option.enabled,
      );
    }).toList();
  }
}
