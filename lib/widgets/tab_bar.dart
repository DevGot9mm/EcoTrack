import 'package:flutter/material.dart';

import '../icons.dart';
import '../store.dart';
import '../theme.dart';
import 'common.dart';

/// Primary bottom navigation. Hidden on the onboarding, auth, add and result
/// routes, exactly like the prototype's tab bar.
class EcoTabBar extends StatelessWidget {
  const EcoTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final String active = store.activeTab;

    final List<Widget> tabs = <Widget>[];
    for (final TabSpec t in kTabs) {
      final bool on = t.id == active;
      tabs.add(
        Expanded(
          child: Pressable(
            onTap: () => store.go(t.id),
            scale: 0.94,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Transform.translate(
                        offset: Offset(0, on ? -1 : 0),
                        child: Transform.scale(
                          scale: on ? 1.06 : 1,
                          child: EcoIcon(
                            t.icon,
                            size: 21,
                            color: on ? cs.leaf : cs.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        t.label,
                        style: F.b(
                          11,
                          wght: 700,
                          color: on ? cs.leaf : cs.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (on)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 3,
                    child: Center(
                      child: Container(
                        width: 18,
                        height: 3,
                        decoration: BoxDecoration(
                          color: cs.forest,
                          borderRadius: BorderRadius.circular(Eco.rPill),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
        child: SizedBox(height: Eco.tabbarH, child: Row(children: tabs)),
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
              style: F.b(14, wght: 700, color: const Color(0xFFF0F8EA)),
            ),
          ),
        ],
      ),
    );
  }
}
