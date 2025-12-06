import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_tracker/app_startup.dart';
import 'package:life_tracker/core/constants/app_theme.dart';
import 'package:life_tracker/core/router/app_router.dart';
import 'package:life_tracker/core/widgets/app_lock_wrapper.dart';
import 'package:life_tracker/features/settings/presentation/providers/settings_provider.dart';
import 'package:life_tracker/l10n/generated/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: LifeTrackerApp(),
    ),
  );
}

class LifeTrackerApp extends ConsumerWidget {
  const LifeTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the AppStartupWidget to handle initialization.
    return AppStartupWidget(
      onLoaded: (context) => AppLockWrapper(
        child: Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(settingsProvider);
            // Get locale from settings
            final locale = Locale(settings.language);

            return MaterialApp.router(
              title: 'Life Tracker',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settings.themeMode,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
