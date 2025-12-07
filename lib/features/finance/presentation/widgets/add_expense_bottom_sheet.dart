import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/utils/thousands_separator_formatter.dart';
import 'package:life_tracker/features/finance/domain/entities/expense.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/providers/category_provider.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/providers/expense_provider.dart';
import 'package:life_tracker/shared/widgets/fields/app_text_field.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AddExpenseBottomSheet extends ConsumerStatefulWidget {
  final Expense? expense;
  final int? preSelectedAccountId;

  const AddExpenseBottomSheet({
    super.key,
    this.expense,
    this.preSelectedAccountId,
  });

  @override
  ConsumerState<AddExpenseBottomSheet> createState() =>
      _AddExpenseBottomSheetState();
}

class _AddExpenseBottomSheetState extends ConsumerState<AddExpenseBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedCurrency = 'EGP';
  String? _selectedCategoryId;
  String? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;

  final List<String> _currencies = ['USD', 'EGP'];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final expense = widget.expense!;
      final numberFormat = NumberFormat('#,##0.00');
      _amountController.text = numberFormat.format(expense.amount);
      _selectedCurrency = expense.currency;
      _selectedCategoryId = expense.categoryId.toString();
      _selectedAccountId = expense.accountId.toString();
      _selectedDate = expense.date;
      _noteController.text = expense.note ?? '';
      _receiptPath = expense.receiptPath;
    } else if (widget.preSelectedAccountId != null) {
      _selectedAccountId = widget.preSelectedAccountId.toString();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickReceipt() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        // Save to app documents directory using copy instead of saveTo
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final destinationPath = '${directory.path}/$fileName';

        // Copy the file instead of using saveTo
        final sourceFile = File(image.path);
        await sourceFile.copy(destinationPath);

        setState(() {
          _receiptPath = destinationPath;
        });
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Failed to capture image: $e');
      }
    }
  }

  Future<void> _pickReceiptFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        // Save to app documents directory using copy instead of saveTo
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final destinationPath = '${directory.path}/$fileName';

        // Copy the file instead of using saveTo
        final sourceFile = File(image.path);
        await sourceFile.copy(destinationPath);

        setState(() {
          _receiptPath = destinationPath;
        });
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get accounts and categories synchronously
    final accountsAsync = ref.read(accountListProvider);
    final categoriesAsync = ref.read(categoriesProvider);

    // Determine category ID - use selected or first available
    int? categoryId;
    categoriesAsync.when(
      data: (categories) {
        if (categories.isNotEmpty) {
          if (_selectedCategoryId != null) {
            categoryId = int.tryParse(_selectedCategoryId!);
          } else {
            // Auto-select first category if none selected
            categoryId = categories.first.id;
            // Update state for next time
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedCategoryId = categoryId.toString();
                });
              }
            });
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    // Determine account ID - use selected or first available
    int? accountId;
    accountsAsync.when(
      data: (accounts) {
        if (accounts.isNotEmpty) {
          if (_selectedAccountId != null) {
            accountId = int.tryParse(_selectedAccountId!);
          } else {
            // Auto-select first account if none selected
            accountId = accounts.first.id;
            // Update state for next time
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedAccountId = accountId.toString();
                });
              }
            });
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    if (categoryId == null) {
      FeedbackService.showWarning(context, 'Please select a category');
      return;
    }

    if (accountId == null) {
      FeedbackService.showWarning(context, 'Please select an account');
      return;
    }

    // Strip commas from formatted numbers before parsing
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    final expense = Expense(
      id: widget.expense?.id,
      amount: amount,
      currency: _selectedCurrency,
      categoryId: categoryId!,
      accountId: accountId!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      receiptPath: _receiptPath,
    );

    try {
      if (widget.expense == null) {
        await ref
            .read(expenseNotifierProvider.notifier)
            .addExpenseEntry(expense);
        // Update account balance
        await _updateAccountBalance(ref, expense.accountId, -expense.amount);

        if (mounted) {
          FeedbackService.showSuccess(context, 'Expense added successfully');
        }
      } else {
        final oldExpense = widget.expense!;
        await ref
            .read(expenseNotifierProvider.notifier)
            .updateExpenseEntry(expense);
        // Update account balances
        if (oldExpense.accountId != expense.accountId) {
          // Account changed - revert old, apply new
          await _updateAccountBalance(
            ref,
            oldExpense.accountId,
            oldExpense.amount,
          );
          await _updateAccountBalance(ref, expense.accountId, -expense.amount);
        } else {
          // Same account - adjust difference
          final difference = oldExpense.amount - expense.amount;
          await _updateAccountBalance(ref, expense.accountId, difference);
        }

        if (mounted) {
          FeedbackService.showSuccess(context, 'Expense updated successfully');
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        FeedbackService.showError(context, 'Error saving expense: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isEditing = widget.expense != null;

    // Auto-select defaults when data becomes available
    accountsAsync.whenData((accounts) {
      if (_selectedAccountId == null && accounts.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedAccountId == null) {
            setState(() {
              _selectedAccountId = accounts.first.id.toString();
            });
          }
        });
      }
    });

    categoriesAsync.whenData((categories) {
      if (_selectedCategoryId == null && categories.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _selectedCategoryId == null) {
            setState(() {
              _selectedCategoryId = categories.first.id.toString();
            });
          }
        });
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Edit Expense' : 'Add Expense',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount
                          AppTextField(
                            controller: _amountController,
                            label: 'Amount',
                            hint: '0.00',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              ThousandsSeparatorInputFormatter()
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter amount';
                              }
                              // Strip commas before parsing
                              final cleanValue = value.replaceAll(',', '');
                              final amount = double.tryParse(cleanValue);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid amount';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Currency
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCurrency,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(),
                            ),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCurrency = value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Category Dropdown
                          categoriesAsync.when(
                            data: (categories) {
                              if (categories.isEmpty) {
                                return const Text(
                                  'No categories available. Please add a category first.',
                                );
                              }

                              // Auto-select first category if none selected
                              if (_selectedCategoryId == null &&
                                  categories.isNotEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted && _selectedCategoryId == null) {
                                    setState(() {
                                      _selectedCategoryId =
                                          categories.first.id.toString();
                                    });
                                  }
                                });
                              }

                              return DropdownButtonFormField<String>(
                                initialValue: _selectedCategoryId ??
                                    categories.first.id.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                ),
                                items: categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category.id.toString(),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(category.icon),
                                          color:
                                              _getCategoryColor(category.color),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(category.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategoryId = value;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a category';
                                  }
                                  return null;
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) =>
                                Text('Error loading categories: $error'),
                          ),
                          const SizedBox(height: 16),
                          // Account Selector
                          Text(
                            'Account',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          accountsAsync.when(
                            data: (accounts) {
                              if (accounts.isEmpty) {
                                return const Text(
                                  'No accounts available. Please add an account first.',
                                );
                              }

                              // Auto-select first account if none selected
                              if (_selectedAccountId == null &&
                                  accounts.isNotEmpty) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted && _selectedAccountId == null) {
                                    setState(() {
                                      _selectedAccountId =
                                          accounts.first.id.toString();
                                    });
                                  }
                                });
                              }

                              return DropdownButtonFormField<String>(
                                initialValue: _selectedAccountId ??
                                    accounts.first.id.toString(),
                                decoration: const InputDecoration(
                                  labelText: 'Select Account',
                                  border: OutlineInputBorder(),
                                ),
                                items: accounts.map((account) {
                                  return DropdownMenuItem(
                                    value: account.id.toString(),
                                    child: Text(account.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedAccountId = value);
                                  }
                                },
                              );
                            },
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) =>
                                Text('Error loading accounts: $error'),
                          ),
                          const SizedBox(height: 16),
                          // Date Picker
                          ListTile(
                            title: const Text('Date'),
                            subtitle: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _selectDate,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Note
                          AppTextField(
                            controller: _noteController,
                            label: 'Note (Optional)',
                            hint: 'Add a note...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          // Receipt
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickReceiptFromGallery,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Add Receipt'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _pickReceipt,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                              ),
                            ],
                          ),
                          if (_receiptPath != null) ...[
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.receipt),
                              title: const Text('Receipt attached'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    _receiptPath = null;
                                  });
                                },
                              ),
                            ),
                          ],
                          // Extra space at bottom for keyboard
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveExpense,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(isEditing ? 'Update Expense' : 'Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateAccountBalance(
    WidgetRef ref,
    int accountId,
    double amountChange,
  ) async {
    final accountsAsync = ref.read(accountListProvider);
    accountsAsync.whenData((accounts) {
      final account = accounts.firstWhere(
        (a) => a.id == accountId,
        orElse: () => accounts.first,
      );

      if (account.id != null) {
        final updatedAccount = account.copyWith(
          balance: account.balance + amountChange,
        );
        ref
            .read(accountNotifierProvider.notifier)
            .updateAccountEntry(updatedAccount);
      }
    });
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'directions_car':
        return Icons.directions_car;
      case 'receipt':
        return Icons.receipt;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'face':
        return Icons.face;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
