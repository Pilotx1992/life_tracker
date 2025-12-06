import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:life_tracker/features/health/presentation/providers/medication_provider.dart';
import 'package:life_tracker/shared/widgets/error_widget.dart';
import 'package:life_tracker/shared/widgets/info_card.dart';
import 'package:life_tracker/shared/widgets/states/loading_widget.dart';

class AdherenceStatsCard extends ConsumerWidget {
  final Id medicationId;

  const AdherenceStatsCard({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherenceAsyncValue = ref
        .watch(medicationNotifierProvider.notifier)
        .getAdherence(medicationId);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adherence Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          FutureBuilder<double?>(
            future: adherenceAsyncValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              } else if (snapshot.hasError) {
                return ErrorDisplayWidget(message: snapshot.error.toString());
              } else if (snapshot.hasData && snapshot.data != null) {
                final adherence = snapshot.data! * 100;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adherence: ${adherence.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    LinearProgressIndicator(
                      value: snapshot.data,
                      backgroundColor: Colors.grey[300],
                      color: adherence > 80
                          ? Colors.green
                          : (adherence > 50 ? Colors.orange : Colors.red),
                    ),
                  ],
                );
              } else {
                return const Text('No adherence data available.');
              }
            },
          ),
        ],
      ),
    );
  }
}
