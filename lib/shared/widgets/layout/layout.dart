/// Layout widgets for consistent visual hierarchy
///
/// This library provides reusable layout components:
///
/// ## Section Components
/// - [Section] - A section with optional header and content
/// - [ListSection] - A list section with title header
///
/// ## Card Components
/// - [AppCard] - Consistent card styling with optional elevation
/// - [StatCard] - Card for displaying metrics/stats
///
/// ## Layout Helpers
/// - [PageWrapper] - Consistent page padding and safe area
/// - [ResponsiveContainer] - Responsive width container
/// - [LabeledDivider] - Divider with optional label
/// - [SummaryRow] - Key-value pair display
///
/// Example usage:
/// ```dart
/// // Section with header
/// Section(
///   title: 'Recent Activity',
///   subtitle: 'Last 7 days',
///   child: ListView(...),
/// )
///
/// // App card
/// AppCard(
///   elevated: true,
///   onTap: () => navigateToDetail(),
///   child: Text('Card content'),
/// )
///
/// // Stat card
/// StatCard(
///   label: 'Total Balance',
///   value: '5,000',
///   unit: 'EGP',
///   icon: Icons.account_balance_wallet,
/// )
/// ```
library layout;

export 'layout_widgets.dart';
