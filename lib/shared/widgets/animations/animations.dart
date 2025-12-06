/// Animation widgets for micro-interactions and visual feedback
///
/// This library provides a comprehensive set of animation widgets for:
/// - Button press feedback (AnimatedPressButton, AnimatedIconButton)
/// - Card interactions (AnimatedCard)
/// - List item animations (AnimatedListItem)
/// - Success/Error feedback (SuccessAnimation, ErrorAnimation)
/// - General animations (FadeIn, SlideIn, BounceIn, Pulse)
/// - FAB with bounce (AnimatedFab)
///
/// Example usage:
/// ```dart
/// // Wrap any widget with AnimatedPressButton for tap feedback
/// AnimatedPressButton(
///   onPressed: () => print('Tapped!'),
///   child: Container(child: Text('Press me')),
/// )
///
/// // Use AnimatedCard for list items
/// AnimatedCard(
///   onTap: () => navigateToDetail(),
///   child: ListTile(title: Text('Item')),
/// )
///
/// // Stagger list items
/// ListView.builder(
///   itemBuilder: (context, index) => AnimatedListItem(
///     index: index,
///     child: MyListItem(),
///   ),
/// )
/// ```
library animations;

export 'animated_widgets.dart';
export 'animated_interactive_widgets.dart';
