/// MET-based calorie calculator using scientific formulas
///
/// MET (Metabolic Equivalent of Task) is a unit that estimates
/// the energy cost of physical activities.
///
/// Formula: Kcal/min = (MET × 3.5 × Weight_kg) / 200
class CalorieCalculator {
  /// Calculate calories burned based on steps, duration, and weight
  ///
  /// Uses MET values based on walking cadence (steps per minute)
  /// to provide accurate calorie estimation.
  static double calculateCalories({
    required int steps,
    required Duration duration,
    required double weightKg,
  }) {
    if (duration.inMinutes == 0 || steps == 0) return 0;

    final minutes = duration.inMinutes.toDouble();
    final cadence = steps / minutes;
    final met = getMETValue(cadence);
    final kcalPerMinute = (met * 3.5 * weightKg) / 200;

    return kcalPerMinute * minutes;
  }

  /// Calculate calories for a simple step count estimation
  ///
  /// Uses simpler formula when duration is not available:
  /// Approx 0.04 kcal per step for 70kg person, scaled by weight
  static double calculateCaloriesSimple({
    required int steps,
    required double weightKg,
  }) {
    // Base: 0.04 kcal per step for 70kg person
    // Scale by actual weight
    final weightMultiplier = weightKg / 70.0;
    return steps * 0.04 * weightMultiplier;
  }

  /// Get MET value based on cadence (steps per minute)
  ///
  /// MET values are based on the Compendium of Physical Activities:
  /// - Sedentary: 1.0-1.5 MET
  /// - Light walking: 2.0-3.0 MET
  /// - Moderate walking: 3.0-4.5 MET
  /// - Vigorous walking/jogging: 5.0-8.0 MET
  /// - Running: 8.0+ MET
  static double getMETValue(double cadence) {
    if (cadence < 30) return 1.0; // Sedentary
    if (cadence < 70) return 1.5; // Standing/Light movement
    if (cadence < 100) return 2.5; // Slow Walk
    if (cadence < 120) return 3.5; // Normal Walk
    if (cadence < 140) return 4.5; // Brisk Walk
    if (cadence < 160) return 5.5; // Fast Walk
    if (cadence < 180) return 7.0; // Jogging
    return 9.0; // Running
  }

  /// Get activity description based on cadence
  static String getActivityLevel(double cadence) {
    if (cadence < 30) return 'Sedentary';
    if (cadence < 70) return 'Light';
    if (cadence < 100) return 'Slow Walk';
    if (cadence < 120) return 'Normal Walk';
    if (cadence < 140) return 'Brisk Walk';
    if (cadence < 160) return 'Fast Walk';
    if (cadence < 180) return 'Jogging';
    return 'Running';
  }

  /// Calculate distance in kilometers
  ///
  /// Uses stride length based on height and activity level
  static double calculateDistance({
    required int steps,
    required double heightCm,
    double? cadence,
  }) {
    final strideLength = getStrideLength(heightCm, cadence ?? 100);
    return (steps * strideLength) / 1000; // Convert to km
  }

  /// Get stride length in meters based on height and activity
  ///
  /// Base stride is approximately 41.5% of height for walking
  /// Increases for running due to longer strides
  static double getStrideLength(double heightCm, double cadence) {
    // Base stride is approximately 41.5% of height
    final baseStride = heightCm * 0.415;

    // Adjust for walking speed
    double multiplier = 1.0;
    if (cadence > 120) multiplier = 1.1; // Brisk walk
    if (cadence > 160) multiplier = 1.35; // Running

    return (baseStride * multiplier) / 100; // Return in meters
  }

  /// Calculate exercise minutes based on step count
  ///
  /// Exercise is counted only for intentional physical activity:
  /// - Requires at least 3000 steps threshold
  /// - 150 steps above threshold = 1 minute of exercise
  static double calculateExerciseMinutes(int steps) {
    if (steps < 3000) return 0.0;
    // Every 150 steps above 3000 = 1 minute of exercise
    return ((steps - 3000) / 150).clamp(0.0, 120.0);
  }

  /// Calculate stand hours based on step distribution
  ///
  /// Simple estimation: 500 steps = 1 stand hour
  /// Capped at hours elapsed since midnight
  static double calculateStandHours(int steps, double hoursElapsed) {
    if (steps == 0) return 0.0;
    return (steps / 500).clamp(0.0, hoursElapsed);
  }
}
