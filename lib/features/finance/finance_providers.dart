import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/core/database/database_service.dart';
import 'package:life_tracker/features/finance/data/datasources/account_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/bill_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/category_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/commitment_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/debt_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/expense_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/income_local_data_source.dart';
import 'package:life_tracker/features/finance/data/datasources/transfer_local_data_source.dart';
import 'package:life_tracker/features/finance/data/repositories/account_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/bill_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/category_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/commitment_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/debt_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/expense_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/income_repository_impl.dart';
import 'package:life_tracker/features/finance/data/repositories/transfer_repository_impl.dart';
import 'package:life_tracker/features/finance/domain/repositories/account_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/bill_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/category_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/commitment_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/debt_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/expense_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/income_repository.dart';
import 'package:life_tracker/features/finance/domain/repositories/transfer_repository.dart';

final databaseServiceProvider =
    Provider<DatabaseService>((ref) => DatabaseService.instance);

// Account providers
final accountLocalDataSourceProvider = Provider<AccountLocalDataSource>(
  (ref) => AccountLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepositoryImpl(ref.read(accountLocalDataSourceProvider)),
);

// Category providers
final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>(
  (ref) => CategoryLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepositoryImpl(ref.read(categoryLocalDataSourceProvider)),
);

// Expense providers
final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>(
  (ref) => ExpenseLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseRepositoryImpl(ref.read(expenseLocalDataSourceProvider)),
);

// Income providers
final incomeLocalDataSourceProvider = Provider<IncomeLocalDataSource>(
  (ref) => IncomeLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final incomeRepositoryProvider = Provider<IncomeRepository>(
  (ref) => IncomeRepositoryImpl(ref.read(incomeLocalDataSourceProvider)),
);

// Transfer providers
final transferLocalDataSourceProvider = Provider<TransferLocalDataSource>(
  (ref) => TransferLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final transferRepositoryProvider = Provider<TransferRepository>(
  (ref) => TransferRepositoryImpl(ref.read(transferLocalDataSourceProvider)),
);

// Debt providers
final debtLocalDataSourceProvider = Provider<DebtLocalDataSource>(
  (ref) => DebtLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => DebtRepositoryImpl(ref.read(debtLocalDataSourceProvider)),
);

// Bill providers
final billLocalDataSourceProvider = Provider<BillLocalDataSource>(
  (ref) => BillLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final billRepositoryProvider = Provider<BillRepository>(
  (ref) => BillRepositoryImpl(ref.read(billLocalDataSourceProvider)),
);

// Commitment providers
final commitmentLocalDataSourceProvider = Provider<CommitmentLocalDataSource>(
  (ref) => CommitmentLocalDataSourceImpl(ref.read(databaseServiceProvider)),
);

final commitmentRepositoryProvider = Provider<CommitmentRepository>(
  (ref) =>
      CommitmentRepositoryImpl(ref.read(commitmentLocalDataSourceProvider)),
);
