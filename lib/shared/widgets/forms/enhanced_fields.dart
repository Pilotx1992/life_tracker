import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An enhanced amount/currency input field with formatting and validation
class AmountField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? currencySymbol;
  final String? Function(String?)? validator;
  final ValueChanged<double?>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool enabled;
  final double? initialValue;
  final int decimalPlaces;
  final bool showCurrencyPrefix;

  const AmountField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.currencySymbol,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
    this.enabled = true,
    this.initialValue,
    this.decimalPlaces = 2,
    this.showCurrencyPrefix = true,
  });

  @override
  State<AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<AmountField> {
  late TextEditingController _controller;
  bool _hasInteracted = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null) {
      _controller.text =
          widget.initialValue!.toStringAsFixed(widget.decimalPlaces);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    if (_hasInteracted) {
      _validate(value);
    }

    final amount = double.tryParse(value);
    widget.onChanged?.call(amount);
  }

  void _validate(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  void _onFieldSubmitted(String value) {
    if (!_hasInteracted) {
      setState(() => _hasInteracted = true);
    }
    _validate(value);
    widget.onFieldSubmitted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pattern = widget.decimalPlaces > 0
        ? r'^\d*\.?\d{0,' + widget.decimalPlaces.toString() + r'}$'
        : r'^\d*$';

    return TextFormField(
      controller: _controller,
      focusNode: widget.focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(pattern)),
      ],
      onChanged: _onChanged,
      onFieldSubmitted: _onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText ?? '0.00',
        errorText: _errorText,
        prefixText: widget.showCurrencyPrefix
            ? '${widget.currencySymbol ?? '\$'} '
            : null,
        prefixIcon: !widget.showCurrencyPrefix ? null : null,
        suffixIcon:
            _hasInteracted && _errorText == null && _controller.text.isNotEmpty
                ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                : null,
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// A date picker field with visual feedback
class DatePickerField extends StatelessWidget {
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? labelText;
  final String? hintText;
  final bool enabled;

  const DatePickerField({
    super.key,
    this.value,
    this.firstDate,
    this.lastDate,
    required this.onDateSelected,
    this.labelText,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayDate = value ?? DateTime.now();

    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: displayDate,
                firstDate: firstDate ?? DateTime(2000),
                lastDate: lastDate ?? DateTime(2100),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          enabled: enabled,
        ),
        child: Text(
          value != null
              ? '${displayDate.day}/${displayDate.month}/${displayDate.year}'
              : hintText ?? 'Select date',
          style: value != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ),
    );
  }
}

/// A time picker field with visual feedback
class TimePickerField extends StatelessWidget {
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final String? labelText;
  final String? hintText;
  final bool enabled;

  const TimePickerField({
    super.key,
    this.value,
    required this.onTimeSelected,
    this.labelText,
    this.hintText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled
          ? () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: value ?? TimeOfDay.now(),
              );
              if (picked != null) {
                onTimeSelected(picked);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
          enabled: enabled,
        ),
        child: Text(
          value != null ? value!.format(context) : hintText ?? 'Select time',
          style: value != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ),
    );
  }
}

/// A dropdown field with search capability for long lists
class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String? labelText;
  final String? hintText;
  final bool enabled;
  final bool showSearchBox;
  final int searchThreshold;

  const SearchableDropdown({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    required this.itemLabel,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.showSearchBox = true,
    this.searchThreshold = 10,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget
                .itemLabel(item)
                .toLowerCase()
                .contains(query.toLowerCase()),)
            .toList();
      }
    });
  }

  void _showSelectionDialog() {
    _searchController.clear();
    _filteredItems = widget.items;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Search box (if enabled and items exceed threshold)
              if (widget.showSearchBox &&
                  widget.items.length > widget.searchThreshold)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      _filterItems(value);
                      setModalState(() {});
                    },
                  ),
                ),
              // Items list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = item == widget.value;
                    return ListTile(
                      title: Text(widget.itemLabel(item)),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      selected: isSelected,
                      onTap: () {
                        widget.onChanged(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: widget.enabled ? _showSelectionDialog : null,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          enabled: widget.enabled,
        ),
        child: Text(
          widget.value != null
              ? widget.itemLabel(widget.value as T)
              : widget.hintText ?? 'Select...',
          style: widget.value != null
              ? theme.textTheme.bodyLarge
              : theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
        ),
      ),
    );
  }
}
