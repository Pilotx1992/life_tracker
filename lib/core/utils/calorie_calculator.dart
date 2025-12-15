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
  /// MET thresholds from PRD:
  /// - Sedentary/Standing: Cadence < 70 -> MET 1.2
  /// - Slow Walk: Cadence 70-100 -> MET 3.0
  /// - Brisk Walk: Cadence 100-125 -> MET 4.0
  /// - Run: Cadence > 130 -> MET 8.0+
  static double getMETValue(double cadence) {
    if (cadence < 70) return 1.2;
    if (cadence <= 100) return 3.0;
    if (cadence <= 125) return 4.0;
    if (cadence <= 130) return 6.0; // Interpolation gap (Fast walk)
    return 8.0; // Run
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
