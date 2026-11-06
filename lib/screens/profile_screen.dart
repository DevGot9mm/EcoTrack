import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core/icons.dart';
import '../models/models.dart';
import '../core/responsive.dart';
import '../state/store.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import '../widgets/iso_social_button.dart';
import '../widgets/sheets.dart';

part 'profile/profile_identity_goals.dart';
part 'profile/profile_badges.dart';
part 'profile/profile_social_settings.dart';
part 'profile/profile_settings_forms.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _socialScrollScheduled = false;

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final LevelInfo lvl = levelOf(store.points);
    final cs = Theme.of(context).colorScheme;
    if (store.profileFocusSocial && !_socialScrollScheduled) {
      _socialScrollScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        }
        store.clearSocialProfileFocus();
        _socialScrollScheduled = false;
      });
    }

    return EcoScreen(
      scrollController: _scrollController,
      header: EcoTopBar(
        title: 'Profile',
        right: FlipIconButton(
          tooltip: store.isDark
              ? 'Switch to light appearance'
              : 'Switch to dark appearance',
          frontIcon:
              store.isDark ? Icons.nightlight_round : Icons.wb_sunny_outlined,
          backIcon:
              store.isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          background: cs.surface,
          foreground: cs.muted,
          backBackground: cs.leaf,
          backForeground: cs.onPrimary,
          border: cs.outline,
          onPressed: store.toggleTheme,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(Eco.s20, 0, Eco.s20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 10),
          _ProfileIdentityCard(
            store: store,
            level: lvl,
            onTap: () => _showAvatarPicker(context, store),
          ),
          const SizedBox(height: 18),
          EcoGrid(
            columns: 3,
            gap: 10,
            items: <Widget>[
              StatTile(
                value: fmt1(store.allTimeTotal),
                caption: 'kg total CO₂e',
                valueSize: 17,
              ),
              Pressable(
                onTap: () => showLevelInfoSheet(context, store),
                fillWidth: true,
                borderRadius: BorderRadius.circular(Eco.rCard),
                child: SizedBox(
                  width: double.infinity,
                  child: StatTile(
                    value: groupThousands(store.points),
                    caption: 'Eco Points',
                    valueSize: 17,
                  ),
                ),
              ),
              Pressable(
                onTap: () => showEcoSheet(
                  context,
                  _BadgesSection(store: store),
                  maxHeightFactor: 0.72,
                  maxWidth: 920,
                ),
                fillWidth: true,
                borderRadius: BorderRadius.circular(Eco.rCard),
                child: SizedBox(
                  width: double.infinity,
                  child: StatTile(
                    value: '${store.unlockedBadgeCount}/${store.badges.length}',
                    caption: 'badges',
                    valueSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _GoalsSection(store: store),
          const SizedBox(height: Eco.s24),
          _SettingsSection(store: store),
          const SizedBox(height: Eco.s20),
          _SocialSection(store: store),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}


Future<void> _confirmSignOut(BuildContext context, EcoStore store) async {
  final bool shouldSignOut = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'This resets the local demo profile and restores its sample data.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Log out'),
            ),
          ],
        ),
      ) ??
      false;
  if (shouldSignOut) store.signOut();
}
