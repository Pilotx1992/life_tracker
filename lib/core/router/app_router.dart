import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:life_tracker/features/settings/presentation/screens/profile_setup_screen.dart';
import 'package:life_tracker/features/health/presentation/screens/weight_screen.dart';
import 'package:life_tracker/core/screens/notification_test_screen.dart';

// Finance Screens
import 'package:life_tracker/features/finance/presentation/screens/finance_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/accounts_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/account_detail_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/expenses_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/incomes_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/bills_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/debts_screen.dart';
// Note: Debts detail screen import might be needed if route is added
import 'package:life_tracker/features/finance/presentation/screens/commitments_screen.dart';
import 'package:life_tracker/features/finance/presentation/screens/commitment_detail_screen.dart';

// Entities
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';

// Notebook Screens
import 'package:life_tracker/features/notes/presentation/screens/notes_screen.dart';
import 'package:life_tracker/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:life_tracker/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:life_tracker/features/notes/domain/entities/note.dart';

// Health Screens
import 'package:life_tracker/features/health/presentation/screens/health_screen.dart';
import 'package:life_tracker/features/health/presentation/screens/medications_screen.dart';
import 'package:life_tracker/features/health/presentation/screens/devices_screen.dart';
// Note: Medication detail import if needed

// Reminders Screens
import 'package:life_tracker/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:life_tracker/features/reminders/presentation/widgets/alarm_ringing_screen.dart';

// Settings Screens
import 'package:life_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:life_tracker/features/settings/presentation/screens/app_lock_setup_screen.dart';
import 'package:life_tracker/features/settings/presentation/screens/backup_screen.dart';

/// App routes
class AppRoutes {
// ... existing static const strings ...
  static const String dashboard = '/';
  static const String health = '/health'; // Added health root
  static const String weight = '/health/weight';
  static const String finance = '/finance';
  static const String notes = '/notes';
  static const String reminders = '/reminders';
  static const String alarmRinging = '/reminders/alarm';
  static const String settings = '/settings';
  static const String profileSetup = '/profile/setup';
  static const String notificationTest = '/dev/notifications';

  // Finance
  static const String financeAccounts = '/finance/accounts';
  static const String accountDetail = '/finance/accounts/detail';
  static const String financeExpenses = '/finance/expenses';
  static const String financeIncome = '/finance/income';
  static const String financeBills = '/finance/bills';
  static const String financeDebts = '/finance/debts';
  static const String financeCommitments = '/finance/commitments';
  static const String commitmentDetail = '/finance/commitments/detail';

  // Health
  static const String medications = '/health/medications';
  static const String devices = '/health/devices';

  // Notebook
  static const String noteEditor = '/notes/editor';
  static const String noteDetail = '/notes/detail';

  // Settings
  static const String appLockSetup = '/settings/app-lock';
  static const String backup = '/settings/backup';
  static const String privacyPolicy = '/settings/privacy';
  static const String termsOfService = '/settings/terms';
  static const String licenses = '/settings/licenses';
}

/// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.profileSetup,
      name: 'profile_setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),

    // Health Module
    GoRoute(
      path: AppRoutes.health,
      name: 'health',
      builder: (context, state) => const HealthScreen(),
      routes: [
        GoRoute(
          path: 'weight', // /health/weight
          name: 'weight',
          builder: (context, state) => const WeightScreen(),
        ),
        GoRoute(
          path: 'medications', // /health/medications
          name: 'medications',
          builder: (context, state) => const MedicationsScreen(),
        ),
        GoRoute(
          path: 'devices', // /health/devices
          name: 'devices',
          builder: (context, state) => const DevicesScreen(),
        ),
      ],
    ),

    // Finance Module
    GoRoute(
      path: AppRoutes.finance,
      name: 'finance',
      builder: (context, state) => const FinanceScreen(),
      routes: [
        GoRoute(
          path: 'accounts', // /finance/accounts
          name: 'finance_accounts',
          builder: (context, state) => const AccountsScreen(),
          routes: [
            GoRoute(
              path: 'detail', // /finance/accounts/detail
              name: 'account_detail',
              redirect: (context, state) {
                // Redirect to accounts list if extra is null (app restored)
                if (state.extra == null) {
                  return AppRoutes.financeAccounts;
                }
                return null;
              },
              builder: (context, state) {
                final account = state.extra as Account;
                return AccountDetailScreen(account: account);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'expenses', // /finance/expenses
          name: 'finance_expenses',
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: 'income', // /finance/income
          name: 'finance_income',
          builder: (context, state) => const IncomesScreen(),
        ),
        GoRoute(
          path: 'bills', // /finance/bills
          name: 'finance_bills',
          builder: (context, state) => const BillsScreen(),
        ),
        GoRoute(
          path: 'debts', // /finance/debts
          name: 'finance_debts',
          builder: (context, state) => const DebtsScreen(),
        ),
        GoRoute(
          path: 'commitments', // /finance/commitments
          name: 'finance_commitments',
          builder: (context, state) => const CommitmentsScreen(),
          routes: [
            GoRoute(
              path: 'detail', // /finance/commitments/detail
              name: 'commitment_detail',
              redirect: (context, state) {
                if (state.extra == null) {
                  return AppRoutes.financeCommitments;
                }
                return null;
              },
              builder: (context, state) {
                final commitment = state.extra as FinancialCommitment;
                return CommitmentDetailScreen(commitment: commitment);
              },
            ),
          ],
        ),
      ],
    ),
    // Notebook Module
    GoRoute(
      path: AppRoutes.notes,
      name: 'notes',
      builder: (context, state) => const NotesScreen(),
      routes: [
        GoRoute(
          path: 'editor', // /notes/editor?id=123
          name: 'note_editor',
          builder: (context, state) {
            // First check for extra (backward compatibility)
            final extraNote = state.extra as Note?;
            if (extraNote != null) {
              return NoteEditorScreen(note: extraNote);
            }
            // If no extra, check for query param
            final noteIdStr = state.uri.queryParameters['id'];
            if (noteIdStr != null) {
              final noteId = int.tryParse(noteIdStr);
              if (noteId != null) {
                return NoteEditorScreen(noteId: noteId);
              }
            }
            return const NoteEditorScreen();
          },
        ),
        GoRoute(
          path: 'detail', // /notes/detail
          name: 'note_detail',
          redirect: (context, state) {
            if (state.extra == null) {
              return AppRoutes.notes;
            }
            return null;
          },
          builder: (context, state) {
            final note = state.extra as Note;
            return NoteDetailScreen(note: note);
          },
        ),
      ],
    ),
    // Reminders Module
    GoRoute(
      path: AppRoutes.reminders,
      name: 'reminders',
      builder: (context, state) => const RemindersScreen(),
    ),
    GoRoute(
      path: AppRoutes.alarmRinging,
      name: 'alarm_ringing',
      builder: (context, state) {
        final reminderId = state.uri.queryParameters['id'];
        if (reminderId == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid alarm ID')),
          );
        }
        return AlarmRingingScreen(
          reminderId: int.parse(reminderId),
        );
      },
    ),
    // Settings Module
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'app-lock', // /settings/app-lock
          name: 'app_lock_setup',
          builder: (context, state) => const AppLockSetupScreen(),
        ),
        GoRoute(
          path: 'backup', // /settings/backup
          name: 'backup',
          builder: (context, state) => const BackupScreen(),
        ),
        GoRoute(
          path: 'privacy', // /settings/privacy
          name: 'privacy_policy',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Privacy Policy')),
          ),
        ),
        GoRoute(
          path: 'terms', // /settings/terms
          name: 'terms_of_service',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Terms of Service')),
          ),
        ),
        GoRoute(
          path: 'licenses', // /settings/licenses
          name: 'licenses',
          builder: (context, state) => const LicensePage(),
        ),
      ],
    ),
    // Dev / Diagnostic routes
    GoRoute(
      path: AppRoutes.notificationTest,
      name: 'notification_test',
      builder: (context, state) => const NotificationTestScreen(),
    ),
  ],
  errorBuilder: (context, state) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  },
);
