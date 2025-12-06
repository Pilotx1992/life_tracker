import 'package:flutter/material.dart';

/// Design tokens for consistent spacing, sizing, and layout
class AppDesignTokens {
  AppDesignTokens._();

  // ============================================
  // SPACING SCALE (using 4px base)
  // ============================================

  /// 4dp - Minimal spacing (between tightly related elements)
  static const double space4 = 4.0;

  /// 8dp - Small spacing (between related elements)
  static const double space8 = 8.0;

  /// 12dp - Small-medium spacing
  static const double space12 = 12.0;

  /// 16dp - Medium spacing (default padding)
  static const double space16 = 16.0;

  /// 20dp - Medium-large spacing
  static const double space20 = 20.0;

  /// 24dp - Large spacing (section separation)
  static const double space24 = 24.0;

  /// 32dp - Extra large (major sections)
  static const double space32 = 32.0;

  /// 40dp - Extra extra large
  static const double space40 = 40.0;

  /// 48dp - Touch target minimum / Hero spacing
  static const double space48 = 48.0;

  /// 64dp - Maximum spacing
  static const double space64 = 64.0;

  // ============================================
  // COMMON EDGE INSETS
  // ============================================

  /// Standard page padding (horizontal: 16, vertical: 16)
  static const EdgeInsets pagePadding = EdgeInsets.all(space16);

  /// Horizontal-only page padding
  static const EdgeInsets pageHorizontalPadding =
      EdgeInsets.symmetric(horizontal: space16);

  /// Card internal padding
  static const EdgeInsets cardPadding = EdgeInsets.all(space16);

  /// Compact card padding
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(space12);

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: space12,
  );

  /// Section padding (for separating major sections)
  static const EdgeInsets sectionPadding = EdgeInsets.only(bottom: space24);

  /// Dialog content padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(space24);

  /// Form field spacing
  static const EdgeInsets formFieldPadding = EdgeInsets.only(bottom: space16);

  // ============================================
  // BORDER RADIUS
  // ============================================

  /// 8dp - Small radius (buttons, chips)
  static const double radiusSmall = 8.0;

  /// 12dp - Medium radius (cards, dialogs)
  static const double radiusMedium = 12.0;

  /// 16dp - Large radius (bottom sheets)
  static const double radiusLarge = 16.0;

  /// 24dp - Extra large radius (hero cards)
  static const double radiusXLarge = 24.0;

  /// Full round (circular)
  static const double radiusFull = 9999.0;

  /// Standard card border radius
  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(radiusMedium));

  /// Button border radius
  static const BorderRadius buttonBorderRadius =
      BorderRadius.all(Radius.circular(radiusSmall));

  /// Bottom sheet border radius
  static const BorderRadius bottomSheetBorderRadius = BorderRadius.vertical(
    top: Radius.circular(radiusLarge),
  );

  // ============================================
  // ELEVATION (Material Design 3)
  // ============================================

  /// 0dp - Flat (inline content, lists)
  static const double elevationNone = 0.0;

  /// 1dp - Subtle (cards on background)
  static const double elevationSubtle = 1.0;

  /// 2dp - Low (standard cards)
  static const double elevationSmall = 2.0;

  /// 4dp - Medium (important cards)
  static const double elevationMedium = 4.0;

  /// 8dp - High (FAB, raised elements)
  static const double elevationLarge = 8.0;

  /// 12dp - Highest (modals, dialogs)
  static const double elevationModal = 12.0;

  // ============================================
  // ICON SIZES
  // ============================================

  /// 16dp - Small icons (inline, dense)
  static const double iconSmall = 16.0;

  /// 24dp - Medium icons (standard)
  static const double iconMedium = 24.0;

  /// 32dp - Large icons (prominent)
  static const double iconLarge = 32.0;

  /// 48dp - Extra large (hero, empty states)
  static const double iconXLarge = 48.0;

  /// 64dp - Hero icons
  static const double iconHero = 64.0;

  // ============================================
  // TOUCH TARGETS (Material Design 3)
  // ============================================

  /// 48dp - Minimum touch target size
  static const double minTouchTarget = 48.0;

  /// 56dp - Standard FAB size
  static const double fabSize = 56.0;

  /// 40dp - Mini FAB size
  static const double fabMiniSize = 40.0;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  /// 100ms - Extra fast (micro-interactions)
  static const Duration durationFast = Duration(milliseconds: 100);

  /// 200ms - Short (button feedback)
  static const Duration durationShort = Duration(milliseconds: 200);

  /// 300ms - Medium (page transitions)
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// 500ms - Long (complex animations)
  static const Duration durationLong = Duration(milliseconds: 500);

  /// 800ms - Extended (attention-grabbing)
  static const Duration durationExtended = Duration(milliseconds: 800);

  // ============================================
  // LAYOUT BREAKPOINTS (for responsive design)
  // ============================================

  /// < 600dp - Mobile
  static const double breakpointMobile = 600;

  /// 600-900dp - Tablet
  static const double breakpointTablet = 900;

  /// > 1200dp - Desktop
  static const double breakpointDesktop = 1200;

  // ============================================
  // CONTENT WIDTHS
  // ============================================

  /// 400dp - Narrow content (forms, dialogs)
  static const double contentWidthNarrow = 400;

  /// 600dp - Medium content (cards, lists)
  static const double contentWidthMedium = 600;

  /// 800dp - Wide content (dashboards)
  static const double contentWidthWide = 800;

  /// 1200dp - Maximum content width
  static const double contentWidthMax = 1200;

  // ============================================
  // OPACITY LEVELS
  // ============================================

  /// Full opacity
  static const double opacityFull = 1.0;

  /// High opacity (87% - primary text on light)
  static const double opacityHigh = 0.87;

  /// Medium opacity (60% - secondary text)
  static const double opacityMedium = 0.6;

  /// Low opacity (38% - disabled, hints)
  static const double opacityLow = 0.38;

  /// Very low opacity (12% - subtle backgrounds)
  static const double opacitySubtle = 0.12;

  /// Minimal opacity (5% - hover states)
  static const double opacityMinimal = 0.05;
}

/// Pre-built decorations for common use cases
class AppDecorations {
  AppDecorations._();

  /// Standard card decoration
  static BoxDecoration card(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: AppDesignTokens.cardBorderRadius,
      border: Border.all(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
      ),
    );
  }

  /// Elevated card decoration
  static BoxDecoration cardElevated(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardColor,
      borderRadius: AppDesignTokens.cardBorderRadius,
      boxShadow: [
        BoxShadow(
          color: theme.shadowColor.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Surface container decoration
  static BoxDecoration surface(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: AppDesignTokens.cardBorderRadius,
    );
  }

  /// Outlined decoration
  static BoxDecoration outlined(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      borderRadius: AppDesignTokens.cardBorderRadius,
      border: Border.all(
        color: theme.colorScheme.outline,
      ),
    );
  }
}

/// Helper for consistent spacing widgets
class AppGaps {
  AppGaps._();

  // Vertical gaps
  static const SizedBox v4 = SizedBox(height: AppDesignTokens.space4);
  static const SizedBox v8 = SizedBox(height: AppDesignTokens.space8);
  static const SizedBox v12 = SizedBox(height: AppDesignTokens.space12);
  static const SizedBox v16 = SizedBox(height: AppDesignTokens.space16);
  static const SizedBox v20 = SizedBox(height: AppDesignTokens.space20);
  static const SizedBox v24 = SizedBox(height: AppDesignTokens.space24);
  static const SizedBox v32 = SizedBox(height: AppDesignTokens.space32);
  static const SizedBox v48 = SizedBox(height: AppDesignTokens.space48);

  // Horizontal gaps
  static const SizedBox h4 = SizedBox(width: AppDesignTokens.space4);
  static const SizedBox h8 = SizedBox(width: AppDesignTokens.space8);
  static const SizedBox h12 = SizedBox(width: AppDesignTokens.space12);
  static const SizedBox h16 = SizedBox(width: AppDesignTokens.space16);
  static const SizedBox h20 = SizedBox(width: AppDesignTokens.space20);
  static const SizedBox h24 = SizedBox(width: AppDesignTokens.space24);
  static const SizedBox h32 = SizedBox(width: AppDesignTokens.space32);
}
