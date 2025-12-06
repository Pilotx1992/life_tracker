import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/account.dart';
import 'package:life_tracker/features/finance/presentation/providers/account_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/account_card.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_account_dialog.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/error_widget.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountListAsyncValue = ref.watch(accountListProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(accountNotifierProvider.notifier).loadAccounts();
        },
        child: CustomScrollView(
          slivers: [
            // Summary Section
            SliverToBoxAdapter(
              child: totalBalance != null
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        // Total Balance Card - 3D Style
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              // Main shadow for depth
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: -5,
                              ),
                              // Secondary shadow for 3D effect
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.85),
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // 3D Icon Container
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Balance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: Colors.white
                                                  .withValues(alpha: 0.9),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        NumberFormat.currency(symbol: '\$')
                                            .format(totalBalance),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Credit Card Total - 3D Style
                        Consumer(
                          builder: (context, ref, child) {
                            final creditTotal =
                                ref.watch(creditCardTotalProvider);
                            if (creditTotal != null && creditTotal > 0) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    // Main shadow for depth
                                    BoxShadow(
                                      color:
                                          Colors.orange.withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                      spreadRadius: -5,
                                    ),
                                    // Secondary shadow for 3D effect
                                    BoxShadow(
                                      color:
                                          Colors.orange.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange,
                                        Colors.orange.withValues(alpha: 0.85),
                                        Colors.deepOrange
                                            .withValues(alpha: 0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // 3D Icon Container
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.25),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.credit_card,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Credit Card Limits',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall
                                                  ?.copyWith(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              NumberFormat.currency(
                                                      symbol: '\$')
                                                  .format(creditTotal),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    letterSpacing: -0.5,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 24),
                        // Accounts Section Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(
                                'My Accounts',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const Spacer(),
                              Consumer(
                                builder: (context, ref, child) {
                                  final accountsAsync =
                                      ref.watch(accountListProvider);
                                  return accountsAsync.when(
                                    data: (accounts) => Text(
                                      '${accounts.length} ${accounts.length == 1 ? 'account' : 'accounts'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // Accounts List
            accountListAsyncValue.when(
              data: (accounts) {
                if (accounts.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 100),
                      child: EmptyStateWidget(
                        icon: Icons.account_balance_wallet,
                        title: 'No accounts yet. Add your first account!',
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 100, // Extra padding for FloatingActionButton
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final account = accounts[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == accounts.length - 1 ? 9 : 9,
                          ),
                          child: Dismissible(
                            key: Key('account_${account.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              padding:
                                  const EdgeInsetsDirectional.only(end: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.onError,
                                size: 32,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Account'),
                                      content: Text(
                                        'Are you sure you want to delete ${account.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (direction) {
                              _deleteAccount(context, ref, account);
                            },
                            child: AccountCard(
                              account: account,
                              onTap: () => context.push(
                                AppRoutes.accountDetail,
                                extra: account,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: accounts.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: LoadingWidget(useShimmer: true),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: ErrorDisplayWidget(message: error.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }

  void _deleteAccount(BuildContext context, WidgetRef ref, Account account) {
    if (account.id == null) return;

    ref.read(accountNotifierProvider.notifier).deleteAccountEntry(account.id!);
    FeedbackService.showSuccess(context, '${account.name} deleted');
  }
}
