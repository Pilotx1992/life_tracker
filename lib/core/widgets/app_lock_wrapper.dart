import 'package:flutter/material.dart';
import 'package:life_tracker/core/services/app_lock_service.dart';
import 'package:life_tracker/features/settings/presentation/screens/lock_screen.dart';

/// Widget that wraps the app and handles app lock functionality
class AppLockWrapper extends StatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper>
    with WidgetsBindingObserver {
  final AppLockService _lockService = AppLockService.instance;
  bool _isLocked = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - check if should lock
        _checkLockStatus();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App went to background - no action needed, will check on resume
        break;
    }
  }

  Future<void> _checkLockStatus() async {
    setState(() {
      _isChecking = true;
    });

    final isEnabled = await _lockService.isLockEnabled();

    if (isEnabled) {
      final shouldLock = await _lockService.shouldLock();

      if (mounted) {
        setState(() {
          _isLocked = shouldLock;
          _isChecking = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLocked = false;
          _isChecking = false;
        });
      }
    }
  }

  void _onUnlock() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading while checking lock status
      // Wrap in Directionality since MaterialApp hasn't been built yet
      return const Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_isLocked) {
      // Show lock screen
      // LockScreen should handle its own Directionality, but wrap for safety
      return Directionality(
        textDirection: TextDirection.ltr,
        child: LockScreen(onUnlock: _onUnlock),
      );
    }

    // Show normal app
    return widget.child;
  }
}
