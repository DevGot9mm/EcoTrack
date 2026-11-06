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
  import 'core/responsive.dart';
  import 'state/store.dart';
  import 'core/theme.dart';
  import 'widgets/common.dart';
  import 'widgets/tab_bar.dart';
  import 'widgets/celebrations.dart';

  void main() => runApp(const EcoTrackApp());

  class EcoTrackApp extends StatefulWidget {
    const EcoTrackApp({super.key});

    @override
    State<EcoTrackApp> createState() => _EcoTrackAppState();
  }

  class _EcoTrackAppState extends State<EcoTrackApp> with WidgetsBindingObserver {
    final EcoStore _store = EcoStore();

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addObserver(this);
    }

    @override
    void dispose() {
      WidgetsBinding.instance.removeObserver(this);
      _store.dispose();
      super.dispose();
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.resumed) _store.refreshChallengeWeek();
    }

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
                final MediaQueryData mediaQuery = MediaQuery.of(context);
                return DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium!,
                  child: MediaQuery(
                    data: mediaQuery.copyWith(
                      textScaler:
                          mediaQuery.textScaler.clamp(maxScaleFactor: 1.3),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
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

      if (store.route == AppRoute.welcome) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.ground,
          body: const WelcomeScreen(),
        );
      }
      if (store.route == AppRoute.auth) return const AuthScreen();

      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final bool useSideNavigation = orientation == Orientation.landscape &&
              context.windowSize != WindowSize.compact &&
              store.showTabBar;
          return PopScope(
            canPop: store.canExit,
            onPopInvokedWithResult: (bool didPop, Object? result) {
              if (didPop) return;
              store.back();
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.ground,
              bottomNavigationBar: store.showTabBar && !useSideNavigation
                  ? const EcoTabBar()
                  : null,
              floatingActionButton: store.route == AppRoute.home
                  ? EcoFab(
                      label: 'Log activity',
                      onTap: store.openAdd,
                      tablet: context.windowSize != WindowSize.compact,
                    )
                  : null,
              body: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ColoredBox(
                      color: Theme.of(context).colorScheme.ground,
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Row(
                      children: <Widget>[
                        if (useSideNavigation) const EcoTabBar(vertical: true),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Expanded(
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 1280,
                                        ),
                                        child: _buildBody(store),
                                      ),
                                    ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CelebrationHost(),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget _buildBody(EcoStore store) {
      switch (store.route) {
        case AppRoute.home:
          return const HomeScreen();
        case AppRoute.add:
          return const AddActivityScreen();
        case AppRoute.result:
          return const ResultScreen();
        case AppRoute.history:
          return const HistoryScreen();
        case AppRoute.stats:
          return const StatsScreen();
        case AppRoute.challenges:
          return const ChallengesScreen();
        case AppRoute.tips:
          return const TipsScreen();
        case AppRoute.profile:
        case AppRoute.points:
          return const ProfileScreen();
        case AppRoute.welcome:
        case AppRoute.auth:
          return const HomeScreen();
      }
    }
  }
