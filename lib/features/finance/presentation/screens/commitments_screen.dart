import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/finance/domain/entities/financial_commitment.dart';
import 'package:life_tracker/features/finance/presentation/providers/commitment_provider.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_commitment_dialog.dart';
import 'package:life_tracker/features/finance/presentation/widgets/add_contribution_dialog.dart';
import 'package:life_tracker/core/services/feedback_service.dart';
import 'package:life_tracker/features/finance/presentation/widgets/commitment_card.dart';
import 'package:life_tracker/shared/widgets/states/empty_state_widget.dart';
import 'package:life_tracker/shared/widgets/states/error_widget.dart' as error_widget;
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';

class CommitmentsScreen extends ConsumerStatefulWidget {
  const CommitmentsScreen({super.key});

  @override
  ConsumerState<CommitmentsScreen> createState() => _CommitmentsScreenState();
}

class _CommitmentsScreenState extends ConsumerState<CommitmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commitmentsAsync = ref.watch(commitmentNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Commitments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Commitments Tab
          commitmentsAsync.when(
            data: (commitments) {
              final activeCommitments =
                  commitments.where((c) => !c.isCompleted).toList();
              if (activeCommitments.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.savings,
                  title: 'No Active Commitments',
                  subtitle: 'Add your first financial goal to start tracking',
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(commitmentNotifierProvider.notifier)
                    .loadCommitments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  cacheExtent: 500,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemCount: activeCommitments.length,
                  itemBuilder: (context, index) {
                    final commitment = activeCommitments[index];
                    return Dismissible(
                      key: ValueKey('commitment_${commitment.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
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
                                title: const Text('Delete Commitment'),
                                content: Text(
                                  'Are you sure you want to delete ${commitment.name}?',
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
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (direction) {
                        _deleteCommitment(context, commitment);
                      },
                      child: CommitmentCard(
                        commitment: commitment,
                        onTap: () => _showCommitmentDetail(context, commitment),
                        onAddContribution: () =>
                            _showAddContributionDialog(context, commitment),
                        onEdit: () =>
                            _showEditCommitmentDialog(context, commitment),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const LoadingWidget(useShimmer: true),
            error: (error, stack) =>
                error_widget.ErrorStateWidget(message: error.toString()),
          ),
          // Completed Commitments Tab
          commitmentsAsync.when(
            data: (commitments) {
              final completedCommitments =
                  commitments.where((c) => c.isCompleted).toList();
              if (completedCommitments.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.check_circle,
                  title: 'No Completed Commitments',
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(commitmentNotifierProvider.notifier)
                    .loadCommitments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  cacheExtent: 500,
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  itemCount: completedCommitments.length,
                  itemBuilder: (context, index) {
                    final commitment = completedCommitments[index];
                    return Dismissible(
                      key: ValueKey('commitment_${commitment.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
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
                                title: const Text('Delete Commitment'),
                                content: Text(
                                  'Are you sure you want to delete ${commitment.name}?',
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
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ) ??
                            false;
                      },
                      onDismissed: (direction) {
                        _deleteCommitment(context, commitment);
                      },
                      child: CommitmentCard(
                        commitment: commitment,
                        onTap: () => _showCommitmentDetail(context, commitment),
                        onEdit: () =>
                            _showEditCommitmentDialog(context, commitment),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const LoadingWidget(useShimmer: true),
            error: (error, stack) =>
                error_widget.ErrorStateWidget(message: error.toString()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCommitmentDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCommitmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCommitmentDialog(),
    );
  }

  void _showEditCommitmentDialog(
    BuildContext context,
    FinancialCommitment commitment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddCommitmentDialog(commitment: commitment),
    );
  }

  void _showAddContributionDialog(
    BuildContext context,
    FinancialCommitment commitment,
  ) {
    showDialog(
      context: context,
      builder: (context) => AddContributionDialog(commitment: commitment),
    );
  }

  void _showCommitmentDetail(
    BuildContext context,
    FinancialCommitment commitment,
  ) {
    context.push(
      AppRoutes.commitmentDetail,
      extra: commitment,
    );
  }

  void _deleteCommitment(BuildContext context, FinancialCommitment commitment) {
    if (commitment.id == null) return;

    ref
        .read(commitmentNotifierProvider.notifier)
        .deleteCommitmentEntry(commitment.id!);
    FeedbackService.showSuccess(context, '${commitment.name} deleted');
  }
}
