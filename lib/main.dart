import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_activity_screen.dart';
import 'screens/result_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/profile_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets/tab_bar.dart';
import 'widgets/celebrations.dart';

void main() => runApp(const EcoTrackApp());

class EcoTrackApp extends StatefulWidget {
  const EcoTrackApp({super.key});

  @override
  State<EcoTrackApp> createState() => _EcoTrackAppState();
}

class _EcoTrackAppState extends State<EcoTrackApp> {
  final EcoStore _store = EcoStore();

  @override
  Widget build(BuildContext context) {
    return EcoScope(
      notifier: _store,
      child: ListenableBuilder(
        listenable: _store,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: 'EcoTrack',
            debugShowCheckedModeBanner: false,
            theme: _store.isDark ? ecoDarkTheme() : ecoTheme(),
            builder: (BuildContext context, Widget? child) {
              return DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppGate(),
          );
        },
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);

    if (store.route == 'welcome') return const WelcomeScreen();
    if (store.route == 'auth') return const AuthScreen();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        store.back();
      },
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.ground,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      _buildBody(store),
                      if (store.toastVisible)
                        Positioned(
                          top: 12,
                          left: 20,
                          right: 20,
                          child: IgnorePointer(
                            child: EcoToast(
                              text: store.toastText,
                              icon: store.toastIcon,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (store.showTabBar) const EcoTabBar(),
              ],
            ),
          ),
          const CelebrationHost(),
        ],
      ),
    );
  }

  Widget _buildBody(EcoStore store) {
    switch (store.route) {
      case 'home':
        return const HomeScreen();
      case 'add':
        return const AddActivityScreen();
      case 'result':
        return const ResultScreen();
      case 'history':
        return const HistoryScreen();
      case 'stats':
        return const StatsScreen();
      case 'challenges':
        return const ChallengesScreen();
      case 'tips':
        return const TipsScreen();
      case 'profile':
      case 'points':
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
