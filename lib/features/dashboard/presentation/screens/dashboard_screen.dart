import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:life_tracker/core/constants/app_design_tokens.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/features/settings/presentation/providers/user_profile_providers.dart';

/// Premium Dashboard Screen with vibrant colors and animations
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Gradient background animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);

    // Card entrance animation
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutCubic,
    ));

    _cardController.forward();
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for user profile availability
    ref.listen<AsyncValue<dynamic>>(userProfileProvider, (previous, next) {
      if (next is AsyncData) {
        final profile = next.value as Object?;
        if (profile == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.push(AppRoutes.profileSetup);
          });
        }
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.track_changes,
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Life Tracker',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color:
                  (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(AppRoutes.settings),
              tooltip: 'Settings',
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0D1B2A),
                        const Color(0xFF1B263B),
                        const Color(0xFF0D1B2A),
                      ]
                    : [
                        Color.lerp(
                          const Color(0xFFF8FAFF),
                          const Color(0xFFE8F4FF),
                          _gradientController.value,
                        )!,
                        Color.lerp(
                          const Color(0xFFFFE8F5),
                          const Color(0xFFF0E8FF),
                          _gradientController.value,
                        )!,
                        Color.lerp(
                          const Color(0xFFE8FFEF),
                          const Color(0xFFFFF8E8),
                          _gradientController.value,
                        )!,
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: AppDesignTokens.space16,
              right: AppDesignTokens.space16,
              bottom: AppDesignTokens.space32,
              top: AppDesignTokens.space16,
            ),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section with animated gradient text
                    _GreetingSection(
                      greeting: _getGreeting(),
                      emoji: _getGreetingEmoji(),
                    ),
                    const SizedBox(height: AppDesignTokens.space24),

                    // Module Cards with staggered animation
                    _buildModuleSection(context, theme, isDark),
                    const SizedBox(height: AppDesignTokens.space32),

                    // Quick Stats Section
                    _buildQuickStats(context, theme, isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final modules = [
      _ModuleData(
        icon: Icons.favorite_rounded,
        title: 'Health',
        subtitle: 'Track wellness & vitals',
        gradient: const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
        darkGradient: const [Color(0xFFD64545), Color(0xFFAF3D3D)],
        route: AppRoutes.weight,
        delay: 0,
      ),
      _ModuleData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Finance',
        subtitle: 'Manage your money',
        gradient: const [Color(0xFF4ECDC4), Color(0xFF6EE7DE)],
        darkGradient: const [Color(0xFF2A9D8F), Color(0xFF238A7F)],
        route: AppRoutes.finance,
        delay: 100,
      ),
      _ModuleData(
        icon: Icons.edit_note_rounded,
        title: 'Notes',
        subtitle: 'Capture your thoughts',
        gradient: const [Color(0xFFFFD93D), Color(0xFFFFE66D)],
        darkGradient: const [Color(0xFFE6B800), Color(0xFFCC9900)],
        route: AppRoutes.notes,
        delay: 200,
      ),
      _ModuleData(
        icon: Icons.notifications_active_rounded,
        title: 'Reminders',
        subtitle: 'Never miss a thing',
        gradient: const [Color(0xFF9B59B6), Color(0xFFBB77D4)],
        darkGradient: const [Color(0xFF7B2D8E), Color(0xFF5E2270)],
        route: AppRoutes.reminders,
        delay: 300,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.apps_rounded,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Modules',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.space16),
        // First row: Health & Finance
        Row(
          children: [
            Expanded(
              child: _PremiumModuleCard(
                data: modules[0], // Health
                isDark: isDark,
                isCompact: true,
                onTap: () => context.push(modules[0].route),
              ),
            ),
            const SizedBox(width: AppDesignTokens.space12),
            Expanded(
              child: _PremiumModuleCard(
                data: modules[1], // Finance
                isDark: isDark,
                isCompact: true,
                onTap: () => context.push(modules[1].route),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.space12),
        // Second row: Notes & Reminders
        Row(
          children: [
            Expanded(
              child: _PremiumModuleCard(
                data: modules[2], // Notes
                isDark: isDark,
                isCompact: true,
                onTap: () => context.push(modules[2].route),
              ),
            ),
            const SizedBox(width: AppDesignTokens.space12),
            Expanded(
              child: _PremiumModuleCard(
                data: modules[3], // Reminders
                isDark: isDark,
                isCompact: true,
                onTap: () => context.push(modules[3].route),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: theme.colorScheme.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Stats',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.space16),

        // Stats Grid with glassmorphic cards
        Row(
          children: [
            Expanded(
              child: _GlassStatCard(
                icon: Icons.trending_up_rounded,
                label: 'Activity',
                value: '87%',
                color: const Color(0xFF4ECDC4),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppDesignTokens.space12),
            Expanded(
              child: _GlassStatCard(
                icon: Icons.check_circle_rounded,
                label: 'Tasks',
                value: '12',
                color: const Color(0xFF9B59B6),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDesignTokens.space12),
        Row(
          children: [
            Expanded(
              child: _GlassStatCard(
                icon: Icons.favorite_rounded,
                label: 'Health',
                value: 'Good',
                color: const Color(0xFFFF6B6B),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppDesignTokens.space12),
            Expanded(
              child: _GlassStatCard(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Balance',
                value: '+\$240',
                color: const Color(0xFF2ECC71),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Greeting section with gradient text effect
class _GreetingSection extends StatelessWidget {
  final String greeting;
  final String emoji;

  const _GreetingSection({
    required this.greeting,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesignTokens.space24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusXLarge),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    greeting,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getMotivationalQuote(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      'Every day is a new opportunity to grow.',
      'Small steps lead to big achievements.',
      'Your potential is limitless.',
      'Make today count!',
      'Progress, not perfection.',
    ];
    return quotes[DateTime.now().day % quotes.length];
  }
}

/// Data model for module cards
class _ModuleData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final List<Color> darkGradient;
  final String route;
  final int delay;

  const _ModuleData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.darkGradient,
    required this.route,
    required this.delay,
  });
}

/// Premium module card with glassmorphic effect
class _PremiumModuleCard extends StatefulWidget {
  final _ModuleData data;
  final bool isDark;
  final bool isCompact;
  final VoidCallback onTap;

  const _PremiumModuleCard({
    required this.data,
    required this.isDark,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_PremiumModuleCard> createState() => _PremiumModuleCardState();
}

class _PremiumModuleCardState extends State<_PremiumModuleCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        widget.isDark ? widget.data.darkGradient : widget.data.gradient;

    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(
                    alpha: 0.3 + (_glowAnimation.value * 0.2),
                  ),
                  blurRadius: 12 + (_glowAnimation.value * 8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          setState(() => _isPressed = true);
          _hoverController.forward();
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _hoverController.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _hoverController.reverse();
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            widget.isCompact
                ? AppDesignTokens.space16
                : AppDesignTokens.space20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
          ),
          child: widget.isCompact
              ? _buildCompactLayout(theme)
              : _buildFullLayout(theme),
        ),
      ),
    );
  }

  Widget _buildCompactLayout(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon without background
        Icon(
          widget.data.icon,
          color: Colors.white,
          size: 40,
        ),
        const SizedBox(height: AppDesignTokens.space12),
        // Title
        Text(
          widget.data.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFullLayout(ThemeData theme) {
    return Row(
      children: [
        // Icon with glass background
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMedium),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            widget.data.icon,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: AppDesignTokens.space16),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.data.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),

        // Arrow with animated container
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

/// Glassmorphic stat card
class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _GlassStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.space16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusLarge),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
