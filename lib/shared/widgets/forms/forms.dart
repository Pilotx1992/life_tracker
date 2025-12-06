/// Form UX utilities for improved user experience
///
/// This library provides enhanced form widgets and utilities:
///
/// ## Smart Text Fields
/// - [SmartTextField] - Real-time validation with success indicators
/// - [AmountField] - Currency input with formatting
///
/// ## Date/Time Pickers
/// - [DatePickerField] - Date selection with visual feedback
/// - [TimePickerField] - Time selection with visual feedback
///
/// ## Dropdowns
/// - [SearchableDropdown] - Dropdown with search for long lists
///
/// ## Form State Management
/// - [UnsavedChangesWrapper] - Warns before losing unsaved changes
/// - [FormChangeTracker] - Mixin for tracking form changes
///
/// ## Input Formatters
/// - [CurrencyInputFormatter] - Formats currency values
/// - [PhoneNumberInputFormatter] - Formats phone numbers
///
/// ## Validators
/// - [FormValidators] - Common validation functions
///
/// Example usage:
/// ```dart
/// // Smart text field with validation
/// SmartTextField(
///   controller: _nameController,
///   labelText: 'Name',
///   validator: FormValidators.required,
/// )
///
/// // Amount field
/// AmountField(
///   labelText: 'Amount',
///   currencySymbol: 'EGP',
///   onChanged: (amount) => print(amount),
/// )
///
/// // Wrap form to warn about unsaved changes
/// UnsavedChangesWrapper(
///   hasUnsavedChanges: _hasChanges,
///   child: MyFormWidget(),
/// )
/// ```
library forms;

export 'form_widgets.dart';
export 'enhanced_fields.dart';
