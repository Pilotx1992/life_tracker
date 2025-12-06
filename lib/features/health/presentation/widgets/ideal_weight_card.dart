import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/shared/widgets/info_card.dart';

class IdealWeightCard extends ConsumerWidget {
  final double height;
  final bool isMale;

  const IdealWeightCard({
    super.key,
    required this.height,
    required this.isMale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idealWeightAsyncValue = ref.watch(
      idealWeightProvider(IdealWeightParams(height: height, isMale: isMale)),
    );

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ideal Weight Range',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          idealWeightAsyncValue.when(
            data: (idealWeight) {
              if (idealWeight == null) {
                return const Text('Ideal weight not available');
              }
              return Text(
                '${idealWeight['min']?.toStringAsFixed(1)} - ${idealWeight['max']?.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) =>
                Text('Error calculating ideal weight: $error'),
          ),
        ],
      ),
    );
  }
}
