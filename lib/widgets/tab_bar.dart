import 'package:flutter/material.dart';

import '../core/icons.dart';
import '../state/store.dart';
import '../core/theme.dart';

/// Primary bottom navigation. Hidden on the onboarding, auth, add and result
/// routes, exactly like the prototype's tab bar.
class EcoTabBar extends StatelessWidget {
  const EcoTabBar({super.key, this.vertical = false});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final int selectedIndex =
        kTabs.indexWhere((TabSpec tab) => tab.route == store.activeTab);
    final List<NavigationDestination> destinations = kTabs
        .map(
          (TabSpec tab) => NavigationDestination(
            icon: Icon(kIcons[tab.icon]),
            selectedIcon: Icon(kIcons[tab.icon]),
            label: tab.label,
          ),
        )
        .toList();

    if (vertical) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(right: BorderSide(color: cs.outline)),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: NavigationRail(
            selectedIndex: selectedIndex,
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (int index) => store.go(kTabs[index].route),
            destinations: kTabs
                .map(
                  (TabSpec tab) => NavigationRailDestination(
                    icon: Icon(kIcons[tab.icon]),
                    selectedIcon: Icon(kIcons[tab.icon]),
                    label: Text(tab.label),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
        boxShadow: Eco.shadowTabBar,
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) => store.go(kTabs[index].route),
          destinations: destinations,
        ),
      ),
    );
  }
}

/// Transient status message pinned near the top of the app frame.
class EcoToast extends StatelessWidget {
  const EcoToast({super.key, required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: cs.darkCardEnd,
        borderRadius: BorderRadius.circular(18),
        boxShadow: Eco.shadowToast,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 19, color: cs.sage),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: F.role(context.type.labelLarge!,
                  wght: 700, color: Eco.heroInk),
            ),
          ),
        ],
      ),
    );
  }
}
