import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_bmi.dart';
import 'package:life_tracker/features/health/domain/usecases/calculate_ideal_weight.dart';
import 'package:life_tracker/features/health/presentation/providers/weight_provider.dart';
import 'package:life_tracker/shared/widgets/info_card.dart';

class BmiCard extends ConsumerWidget {
  final double weight;
  final double height;
  final bool isMale;

  const BmiCard({
    super.key,
    required this.weight,
    required this.height,
    required this.isMale,
  });

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 29.9) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi >= 18.5 && bmi < 24.9) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 29.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bmiAsyncValue =
        ref.watch(bmiProvider(BmiParams(weight: weight, height: height)));
    final idealWeightAsyncValue = ref.watch(
      idealWeightProvider(IdealWeightParams(height: height, isMale: isMale)),
    );

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BMI & Ideal Weight',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          bmiAsyncValue.when(
            data: (bmi) {
              if (bmi == null) {
                return const Text('BMI not available');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your BMI: ${bmi.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: _getBmiColor(bmi),
                        ),
                  ),
                  Text(
                    'Category: ${_getBmiCategory(bmi)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error calculating BMI: $error'),
          ),
          const SizedBox(height: 16),
          idealWeightAsyncValue.when(
            data: (idealWeight) {
              if (idealWeight == null) {
                return const Text('Ideal weight not available');
              }
              return Text(
                'Ideal Weight: ${idealWeight['min']?.toStringAsFixed(1)} - ${idealWeight['max']?.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.bodyMedium,
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
