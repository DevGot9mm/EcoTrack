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

void main() => runApp(const EcoTrackApp());

class EcoTrackApp extends StatelessWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoTrack',
      debugShowCheckedModeBanner: false,
      theme: ecoTheme(),
      home: EcoScope(
        notifier: EcoStore(),
        child: const AppGate(),
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

    return SafeArea(
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
