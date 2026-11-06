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
                  maxWidth: 760,
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

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.store,
    required this.level,
    required this.onTap,
  });

  final EcoStore store;
  final LevelInfo level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return EcoCard(
      flat: true,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Tooltip(
            message:
                'Profile picture: ${_avatarName(store.playerAvatar)}. Tap to change.',
            child: CircleAvatar(
              radius: 27,
              backgroundColor: cs.mint,
              child: MascotCrop(
                store.playerAvatar,
                size: 54,
                radius: 27,
                background: cs.mint,
                circular: true,
                photoScale: 1.08,
              ),
            ),
          ),
          const SizedBox(width: Eco.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(store.playerName,
                    style: F.role(context.type.titleMedium!,
                        wght: 600, ls: -0.01)),
                const SizedBox(height: 2),
                Text(
                  'Climate action since ${store.joined} · '
                  'Level ${level.idx + 1} ${level.name}',
                  style: F.role(context.type.labelMedium!,
                      wght: 600, color: cs.muted),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Eco.s4),
          EcoIcon('chevronR', size: 20, color: cs.muted),
        ],
      ),
    );
  }
}

class _GoalsSection extends StatelessWidget {
  const _GoalsSection({required this.store});

  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final double weekTotal = store.total(store.inRange(0, 6));
    final double todayTotal = store.total(store.inRange(0, 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: "This week's goal"),
        EcoCard(
          flat: true,
          padding: const EdgeInsets.all(Eco.s16),
          child: Column(
            children: <Widget>[
              _GoalProgress(
                label: 'Weekly carbon goal',
                value: weekTotal,
                target: store.weeklyTarget,
                categories: store.catTotals(store.inRange(0, 6)),
              ),
              const SizedBox(height: Eco.s16),
              _GoalProgress(
                label: 'Daily carbon goal',
                value: todayTotal,
                target: store.dailyTarget,
                categories: store.catTotals(store.inRange(0, 0)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalProgress extends StatelessWidget {
  const _GoalProgress({
    required this.label,
    required this.value,
    required this.target,
    required this.categories,
  });

  final String label;
  final double value;
  final double target;
  final Map<CarbonCategory, double> categories;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String targetText = '${fmt1(target)} kg';
    final double progress = target <= 0 ? 0 : clampDouble(value / target, 0, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
                child: Text(label,
                    style: F.role(context.type.labelLarge!, wght: 700))),
            Text(targetText,
                style:
                    F.role(context.type.bodySmall!, wght: 800, color: cs.ink2)),
          ],
        ),
        const SizedBox(height: Eco.s8),
        _CarbonMixBar(
          progress: progress,
          total: value,
          categories: categories,
          height: 6,
        ),
      ],
    );
  }
}

class _CarbonMixBar extends StatelessWidget {
  const _CarbonMixBar({
    required this.progress,
    required this.total,
    required this.categories,
    required this.height,
  });

  final double progress;
  final double total;
  final Map<CarbonCategory, double> categories;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final EcoStore store = EcoScope.of(context);
    final double fill = clampDouble(progress, 0, 1);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double filledWidth = constraints.maxWidth * fill;
        final List<CarbonCategory> categoriesInOrder = kCatOrder;
        final List<Widget> segments = <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface2,
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
          ),
        ];
        if (total > 0) {
          double left = 0;
          for (final CarbonCategory category in categoriesInOrder) {
            final double amount = categories[category] ?? 0;
            if (amount <= 0) continue;
            final double width = filledWidth * (amount / total);
            segments.add(
              Positioned(
                left: left,
                top: 0,
                bottom: 0,
                width: width,
                child: ColoredBox(color: store.categoryColor(category)),
              ),
            );
            left += width;
          }
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(Eco.rPill),
          child: SizedBox(
            width: constraints.maxWidth,
            height: height,
            child: Stack(clipBehavior: Clip.hardEdge, children: segments),
          ),
        );
      },
    );
  }
}

const List<String> _avatarOptions = <String>[
  'image.png',
  'image-2.png',
  'image-5.png',
];

String _avatarName(String avatar) =>
    'Portrait ${_avatarOptions.indexOf(avatar) + 1}';

void _showAvatarPicker(BuildContext context, EcoStore store) {
  showEcoSheet(
    context,
    Builder(
      builder: (BuildContext ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SheetTitle(title: 'Choose a profile picture'),
            const SizedBox(height: Eco.s16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _avatarOptions.map((String avatar) {
                final bool selected = store.playerAvatar == avatar;
                return Tooltip(
                  message: 'Use ${_avatarName(avatar)} profile picture',
                  child: Semantics(
                    button: true,
                    selected: selected,
                    label: '${_avatarName(avatar)} profile picture',
                    child: Pressable(
                      onTap: () {
                        store.setPlayerAvatar(avatar);
                        Navigator.of(ctx).pop();
                      },
                      scale: 0.95,
                      child: Container(
                        padding: const EdgeInsets.all(Eco.s4),
                        decoration: BoxDecoration(
                          color: selected ? cs.mint : cs.surface,
                          border: Border.all(
                            color: selected ? cs.leaf : cs.outline,
                            width: selected ? 2 : 1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: cs.mint,
                          child: MascotCrop(
                            avatar,
                            size: 52,
                            radius: 26,
                            circular: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    ),
  );
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.store});
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool wide = context.windowSize != WindowSize.compact;
    final Map<String, int> originalOrder = <String, int>{
      for (int i = 0; i < store.badges.length; i++) store.badges[i].id: i,
    };
    final List<Achievement> orderedBadges = List<Achievement>.of(store.badges)
      ..sort((Achievement a, Achievement b) {
        if (a.unlocked != b.unlocked) return a.unlocked ? 1 : -1;
        return originalOrder[a.id]!.compareTo(originalOrder[b.id]!);
      });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Badges'),
        const SizedBox(height: Eco.s12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 5 : 3,
            crossAxisSpacing: wide ? 12 : 10,
            mainAxisSpacing: wide ? 12 : 10,
            childAspectRatio: wide ? 1.1 : 0.82,
          ),
          itemCount: orderedBadges.length,
          itemBuilder: (BuildContext context, int i) {
            final Achievement b = orderedBadges[i];
            return _BadgeItem(
              b: b,
              cs: cs,
              onTap: () => _showBadgeDetail(context, b),
            );
          },
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context, Achievement b) {
    final cs = Theme.of(context).colorScheme;
    showEcoSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: b.unlocked ? cs.mint : cs.surface2,
                shape: BoxShape.circle,
              ),
              child: EcoIcon(b.icon,
                  size: 26, color: b.unlocked ? cs.leaf : cs.muted),
            ),
          ),
          const SizedBox(height: Eco.s12),
          Text(
            b.name,
            style: F.d(18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Eco.s4),
          Text(
            b.desc,
            style:
                F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Eco.s12),
          Text(
            b.unlocked ? 'Unlocked' : 'Locked',
            style: F.role(context.type.bodySmall!,
                wght: 800, color: b.unlocked ? cs.leaf : cs.muted),
          ),
          const SizedBox(height: Eco.s12),
          EcoBar(
            value: b.progress / b.target,
            color: b.unlocked ? cs.leaf : cs.muted,
            height: 8,
          ),
          const SizedBox(height: 6),
          Text(
            '${b.progress.round()} of ${b.target.round()} complete',
            style:
                F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          EcoButton(
            label: 'Close',
            block: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      maxHeightFactor: 0.72,
      maxWidth: 760,
    );
  }
}

class _BadgeItem extends StatefulWidget {
  const _BadgeItem({required this.b, required this.cs, required this.onTap});

  final Achievement b;
  final ColorScheme cs;
  final VoidCallback onTap;

  @override
  State<_BadgeItem> createState() => _BadgeItemState();
}

class _BadgeItemState extends State<_BadgeItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final double angle = _hovering ? math.pi : 0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: angle),
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeInOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            final bool showingBack = value > math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(value),
              child: HolographicCard(
                borderRadius: Eco.rCard,
                backgroundColor: Colors.transparent,
                hoverScale: 1.01,
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        widget.b.unlocked ? widget.cs.mint : widget.cs.surface,
                    border: Border.all(
                      color: widget.b.unlocked
                          ? widget.cs.outline
                          : widget.cs.lineStrong,
                    ),
                    borderRadius: BorderRadius.circular(Eco.rCard),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: showingBack
                      ? _backFace(widget.cs)
                      : _frontFace(widget.cs),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _frontFace(ColorScheme cs) {
    final Achievement b = widget.b;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: b.unlocked ? cs.mint : cs.surface3,
            shape: BoxShape.circle,
          ),
          child: EcoIcon(
            b.icon,
            size: 24,
            color: b.unlocked ? cs.leaf : cs.muted,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          b.name,
          style: F.b(11.5, wght: 800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '${b.progress.round()}/${b.target.round()}',
          style: F.b(12, height: 1.3, color: cs.muted),
        ),
        const SizedBox(height: Eco.s4),
        SizedBox(
          height: 5,
          child: b.unlocked
              ? Center(child: EcoIcon('check', size: 14, color: cs.leaf))
              : EcoBar(value: b.progress / b.target, color: cs.leaf, height: 5),
        ),
      ],
    );
  }

  Widget _backFace(ColorScheme cs) {
    final Achievement b = widget.b;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(math.pi),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            b.name,
            style: F.b(12, wght: 800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: Text(
                b.desc,
                style: F.b(11, height: 1.3, color: cs.ink2),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Text(
            b.unlocked ? 'Achieved' : 'In progress',
            style: F.b(11, wght: 800, color: b.unlocked ? cs.leaf : cs.muted),
          ),
          const SizedBox(height: 3),
          Text(
            '${b.progress.round()} of ${b.target.round()}',
            style: F.b(11, color: cs.muted),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.store});
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final List<_SettingsRow> settings = <_SettingsRow>[
      _SettingsRow(
        icon: 'target',
        label: 'Carbon target',
        trailing: '${fmt1(store.dailyTarget)} kg / day',
        onTap: () => _showTargetPicker(context, store),
      ),
      _SettingsRow(
        icon: 'tips',
        label: 'Tips',
        onTap: () => store.go(AppRoute.tips),
      ),
      _SettingsRow(
        icon: 'shield',
        label: 'Account & security',
        onTap: () => _showAccountSettings(context, store),
      ),
      _SettingsRow(
        icon: 'settings',
        label: 'Units & colors',
        trailing: store.distanceUnit,
        onTap: () => _showUnitSettings(context, store),
      ),
      _SettingsRow(
        icon: 'help',
        label: 'Help & support',
        onTap: () => _showHelp(context, store),
      ),
      _SettingsRow(
        icon: 'book',
        label: 'About EcoTrack',
        onTap: () => _showAbout(context),
      ),
      _SettingsRow(
        icon: 'logout',
        label: 'Log out',
        danger: true,
        onTap: () => _confirmSignOut(context, store),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Account'),
        const SizedBox(height: Eco.s8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool tablet = context.windowSize != WindowSize.compact;
            final double itemWidth =
                tablet ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final _SettingsRow setting in settings)
                  SizedBox(
                    width: itemWidth,
                    child: _SettingsRow(
                      icon: setting.icon,
                      label: setting.label,
                      onTap: setting.onTap,
                      trailing: setting.trailing,
                      danger: setting.danger,
                      roomy: tablet,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.store});

  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Follow EcoTrack'),
        const SizedBox(height: Eco.s4),
        Text(
          'Social account links are placeholders until official URLs are set.',
          style: F.role(context.type.labelSmall!, color: cs.muted),
        ),
        const SizedBox(height: 66),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 30,
          runSpacing: 66,
          children: <IsoSocialButton>[
            IsoSocialButton(
              icon: FontAwesomeIcons.instagram,
              label: 'Instagram',
              hoverFace: EcoBrand.instagramFace,
              hoverLeft: EcoBrand.instagramLeft,
              hoverBottom: EcoBrand.instagramBottom,
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () => _openSocialLink(store, 'Instagram'),
            ),
            IsoSocialButton(
              icon: FontAwesomeIcons.tiktok,
              label: 'TikTok',
              hoverFace: EcoBrand.blackFace,
              hoverLeft: EcoBrand.blackLeft,
              hoverBottom: EcoBrand.blackBottom,
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () => _openSocialLink(store, 'TikTok'),
            ),
            IsoSocialButton(
              icon: FontAwesomeIcons.xTwitter,
              label: 'X',
              hoverFace: EcoBrand.blackFace,
              hoverLeft: EcoBrand.blackLeft,
              hoverBottom: EcoBrand.blackBottom,
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () => _openSocialLink(store, 'X'),
            ),
          ],
        ),
      ],
    );
  }

  void _openSocialLink(EcoStore store, String platform) {
    store.toast('The official EcoTrack $platform link is not configured yet');
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.danger = false,
    this.roomy = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool danger;
  final bool roomy;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      borderRadius: BorderRadius.circular(Eco.rSm),
      child: Container(
        constraints: BoxConstraints(minHeight: roomy ? 72 : 0),
        padding: EdgeInsets.symmetric(
          horizontal: Eco.s16,
          vertical: roomy ? 18 : 14,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(Eco.rSm),
        ),
        child: Row(
          children: <Widget>[
            EcoIcon(icon, size: 19, color: cs.leaf),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: F.b(
                  15,
                  wght: 700,
                  color: danger ? cs.danger : cs.ink,
                ),
              ),
            ),
            if (trailing != null) ...<Widget>[
              Text(
                trailing!,
                style: F.role(context.type.labelSmall!,
                    wght: 700, color: cs.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: Eco.s4),
            ],
            EcoIcon(
              'chevronR',
              size: 18,
              color: danger ? cs.danger : cs.muted,
            ),
          ],
        ),
      ),
    );
  }
}

void _showTargetPicker(BuildContext context, EcoStore store) {
  showEcoSheet(
    context,
    Builder(
      builder: (BuildContext ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SheetTitle(title: 'Daily carbon target'),
            const SizedBox(height: Eco.s4),
            Text(
              'Pick the number you want EcoTrack to measure you against.',
              style: F.role(context.type.bodySmall!,
                  color: cs.muted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Eco.s16),
            ...<double>[4, 6, 8].map((double value) {
              final bool selected = value == store.dailyTarget;
              return Pressable(
                onTap: () {
                  Navigator.pop(ctx);
                  store.setDailyTarget(value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Eco.s16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: Eco.s8),
                  decoration: BoxDecoration(
                    color: selected ? cs.mint : cs.surface,
                    border: Border.all(
                      color: selected ? cs.leaf : cs.outline,
                      width: selected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(Eco.rCard),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${value.toInt()} kg CO₂e per day',
                              style: F.b(15, wght: 800),
                            ),
                            Text(
                              value == 4
                                  ? 'Ambitious — close to a 1.5°C-aligned lifestyle.'
                                  : value == 6
                                      ? 'Balanced — the average for a mindful urban household.'
                                      : 'Forgiving — a gentle first step.',
                              style: F.role(context.type.bodySmall!,
                                  color: cs.muted, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      if (selected) EcoIcon('check', size: 20, color: cs.leaf),
                    ],
                  ),
                ),
              );
            }),
            EcoButton(
              label: 'Cancel',
              tone: EcoButtonTone.ghost,
              block: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        );
      },
    ),
  );
}

Future<void> _showAccountSettings(
  BuildContext context,
  EcoStore store,
) async {
  await showEcoSheet(
    context,
    _AccountSettingsForm(
      store: store,
      onChangeAvatar: () => _showAvatarPicker(context, store),
    ),
  );
}

class _AccountSettingsForm extends StatefulWidget {
  const _AccountSettingsForm({
    required this.store,
    required this.onChangeAvatar,
  });

  final EcoStore store;
  final VoidCallback onChangeAvatar;

  @override
  State<_AccountSettingsForm> createState() => _AccountSettingsFormState();
}

class _AccountSettingsFormState extends State<_AccountSettingsForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.store.playerName);
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SheetTitle(title: 'Account & security'),
        const SizedBox(height: 6),
        Text(
          'Profile changes stay in this demo session. Email verification, '
          'password changes, and account recovery need a backend and are '
          'not available yet.',
          style: F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Eco.s16),
        Row(
          children: <Widget>[
            const MascotArt('face-curious', width: 58),
            const SizedBox(width: Eco.s12),
            Expanded(
              child: Text(
                'Personalize your profile and choose how your activity categories look.',
                style: F.role(context.type.bodySmall!,
                    color: cs.ink2, height: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: Eco.s12),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Display name',
            errorText: _error,
          ),
        ),
        const SizedBox(height: 14),
        EcoButton(
          label: 'Save name',
          block: true,
          onPressed: () {
            if (_name.text.trim().length < 2) {
              setState(() => _error = 'Enter at least two characters.');
              return;
            }
            widget.store.setPlayerName(_name.text);
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: Eco.s8),
        EcoButton(
          label: 'Change profile picture',
          leading: 'user',
          tone: EcoButtonTone.ghost,
          block: true,
          onPressed: () {
            Navigator.pop(context);
            widget.onChangeAvatar();
          },
        ),
      ],
    );
  }
}

void _showUnitSettings(BuildContext context, EcoStore store) {
  showEcoSheet(
    context,
    Builder(
      builder: (BuildContext ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SheetTitle(title: 'Units & category colors'),
            const SizedBox(height: Eco.s4),
            Text(
              'Used for transport activity input and history.',
              style: F.role(context.type.bodySmall!,
                  color: cs.muted, height: 1.45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Eco.s12),
            _UnitChoice(
              value: 'km',
              label: 'Kilometres',
              selected: store.distanceUnit == 'km',
              onTap: () {
                Navigator.pop(ctx);
                store.setDistanceUnit('km');
              },
            ),
            _UnitChoice(
              value: 'mi',
              label: 'Miles',
              selected: store.distanceUnit == 'mi',
              onTap: () {
                Navigator.pop(ctx);
                store.setDistanceUnit('mi');
              },
            ),
            const SizedBox(height: 22),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Carbon source colors',
                  style:
                      F.role(context.type.titleMedium!, wght: 600, ls: -0.01)),
            ),
            const SizedBox(height: Eco.s4),
            Text(
              'Choose a color for each category. Your selection updates charts, bars, and category indicators.',
              style: F.role(context.type.bodySmall!,
                  color: cs.muted, height: 1.45),
            ),
            const SizedBox(height: Eco.s12),
            _CategoryColorPicker(store: store),
          ],
        );
      },
    ),
  );
}

class _CategoryColorPicker extends StatefulWidget {
  const _CategoryColorPicker({required this.store});

  final EcoStore store;

  @override
  State<_CategoryColorPicker> createState() => _CategoryColorPickerState();
}

class _CategoryColorPickerState extends State<_CategoryColorPicker> {
  static const List<Color> _palette = Eco.categoryPalette;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      children: <Widget>[
        for (final CarbonCategory id in kCatOrder) ...<Widget>[
          EcoCard(
            flat: true,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: Eco.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: widget.store.categoryColor(id),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: Eco.s8),
                    Text(catOf(id).name,
                        style: F.role(context.type.labelLarge!, wght: 800)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    for (final Color color in _palette)
                      Semantics(
                        button: true,
                        selected: widget.store.categoryColor(id) == color,
                        label: '${catOf(id).name} color ${_colorHex(color)}',
                        child: Tooltip(
                          message: _colorHex(color),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              widget.store.setCategoryColor(id, color);
                              setState(() {});
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.store.categoryColor(id) == color
                                      ? cs.ink
                                      : cs.outline,
                                  width: widget.store.categoryColor(id) == color
                                      ? 3
                                      : 1,
                                ),
                              ),
                              child: widget.store.categoryColor(id) == color
                                  ? Icon(
                                      Icons.check,
                                      size: 17,
                                      color: color.computeLuminance() < 0.4
                                          ? Colors.white
                                          : Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

String _colorHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

class _UnitChoice extends StatelessWidget {
  const _UnitChoice({
    required this.value,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String value;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Eco.s4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(label, style: F.b(15, wght: 700)),
            ),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? cs.leaf : cs.lineStrong,
                  width: selected ? 7 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showHelp(BuildContext context, EcoStore store) {
  showEcoSheet(
    context,
    LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxWidth = constraints.maxWidth;
        final List<_HelpItem> faqItems = <_HelpItem>[
          const _HelpItem(
            title: 'How are emissions estimated?',
            body:
                'Each activity uses an illustrative emissions factor. Your logged amounts are converted before the estimate is calculated.',
          ),
          const _HelpItem(
            title: 'Where is my data stored?',
            body:
                'This demo keeps data in memory on this device session. It is not synced to an account or server.',
          ),
          const _HelpItem(
            title: 'Are the CO₂e values exact?',
            body:
                'No. The activity factors are educational estimates and can vary by location, provider, product, and individual habits.',
          ),
          const _HelpItem(
            title: 'How do daily challenge check-ins work?',
            body:
                'You can check in once per local calendar day. Challenges that ask for several days require consecutive daily check-ins; a missed day restarts that streak.',
          ),
          const _HelpItem(
            title: 'Can I add an activity that is not listed?',
            body:
                'Yes. Choose the final “Other” option and enter your own total CO₂e estimate. EcoTrack will not infer a factor for it.',
          ),
        ];
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SheetTitle(title: 'Help & support'),
            const SizedBox(height: 14),
            for (int i = 0; i < faqItems.length; i++) ...<Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: faqItems[i],
              ),
              if (i < faqItems.length - 1) const SizedBox(height: Eco.s12),
            ],
            const SizedBox(height: Eco.s12),
            EcoButton(
              label: 'Report an issue',
              leading: 'mail',
              tone: EcoButtonTone.ghost,
              block: true,
              onPressed: () {
                Navigator.pop(context);
                _showReportIssue(context, store);
              },
            ),
            const SizedBox(height: Eco.s8),
            EcoButton(
              label: 'Browse Eco Tips',
              leading: 'tips',
              block: true,
              onPressed: () {
                Navigator.pop(context);
                store.go(AppRoute.tips);
              },
            ),
          ],
        );
      },
    ),
  );
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return EcoCard(
      flat: true,
      background: cs.surface2,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(title, style: F.role(context.type.labelLarge!, wght: 800)),
          const SizedBox(height: Eco.s4),
          Text(body,
              style: F.role(context.type.labelLarge!).copyWith(color: cs.ink2)),
        ],
      ),
    );
  }
}

void _showAbout(BuildContext context) {
  showEcoSheet(
    context,
    Builder(
      builder: (BuildContext ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SheetTitle(title: 'About EcoTrack'),
            const SizedBox(height: Eco.s8),
            Text(
              'EcoTrack makes the climate impact of everyday choices easier '
              'to see. It helps people record transport, household energy, '
              'and food activities, then build lower-impact habits through '
              'tips and weekly challenges.',
              style:
                  F.role(context.type.labelLarge!, color: cs.ink2, height: 1.5),
            ),
            const SizedBox(height: 14),
            EcoCard(
              flat: true,
              tone: EcoCardTone.mint,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('SDG 13 · Climate Action', style: F.d(16)),
                  const SizedBox(height: 5),
                  Text(
                    'The United Nations Sustainable Development Goal 13 calls '
                    'for urgent action to combat climate change and its '
                    'impacts. EcoTrack supports climate awareness and '
                    'individual habit changes; it is an educational project, '
                    'not an official UN product or emissions certification.',
                    style: F.role(context.type.bodySmall!,
                        color: cs.ink2, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Project team', style: F.d(16)),
            const SizedBox(height: 6),
            for (final String member in <String>[
              'Devin Owen Sanusi',
              'Anggara Adelee',
              'Kelvin Kurniawan',
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: <Widget>[
                    EcoIcon('user', size: 17, color: cs.leaf),
                    const SizedBox(width: Eco.s8),
                    Text(member, style: F.b(13.5, wght: 700)),
                  ],
                ),
              ),
            const SizedBox(height: Eco.s8),
            Text(
              'All footprint values are illustrative estimates for learning '
              'and comparison, not audited measurements.',
              style: F.role(context.type.labelMedium!,
                  color: cs.muted, height: 1.4),
            ),
            const SizedBox(height: Eco.s16),
            EcoButton(
              label: 'Close',
              tone: EcoButtonTone.ghost,
              block: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        );
      },
    ),
  );
}

void _showReportIssue(BuildContext context, EcoStore store) {
  showEcoSheet(
    context,
    _ReportIssueForm(store: store),
  );
}

class _ReportIssueForm extends StatefulWidget {
  const _ReportIssueForm({required this.store});

  final EcoStore store;

  @override
  State<_ReportIssueForm> createState() => _ReportIssueFormState();
}

class _ReportIssueFormState extends State<_ReportIssueForm> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _details = TextEditingController();
  String? _titleError;
  String? _detailsError;

  /// Feedback shown inside the sheet (toasts are hidden behind the modal).
  String? _statusMessage;
  bool _copied = false;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SheetTitle(title: 'Report an issue'),
        const SizedBox(height: 6),
        Text(
          'Choose an app from your device’s share sheet to send or save your '
          'report. EcoTrack will not upload it directly.',
          style: F.role(context.type.bodySmall!, color: cs.muted, height: 1.45),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _title,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_titleError != null) setState(() => _titleError = null);
          },
          decoration: InputDecoration(
            labelText: 'Short title',
            errorText: _titleError,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _details,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_detailsError != null) setState(() => _detailsError = null);
          },
          decoration: InputDecoration(
            labelText: 'What happened?',
            errorText: _detailsError,
          ),
        ),
        const SizedBox(height: 14),
        if (_statusMessage != null) ...<Widget>[
          Text(
            _statusMessage!,
            key: const ValueKey<String>('report-status'),
            style: F.role(
              context.type.bodySmall!,
              color: _copied ? cs.primary : cs.error,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Builder(
          builder: (BuildContext context) => EcoButton(
            label: 'Share report',
            leading: 'share',
            block: true,
            onPressed: () => _shareReport(context),
          ),
        ),
        if (_statusMessage != null) ...<Widget>[
          const SizedBox(height: 10),
          EcoButton(
            label: 'Copy report to clipboard',
            leading: 'info',
            tone: EcoButtonTone.ghost,
            block: true,
            onPressed: _copyReport,
          ),
        ],
      ],
    );
  }

  /// Validates the form; returns the report text or null when invalid.
  String? _validatedReport() {
    final String title = _title.text.trim();
    final String details = _details.text.trim();
    if (title.length < 3 || details.length < 10) {
      setState(() {
        _titleError = title.length < 3 ? 'Add a short title' : null;
        _detailsError =
            details.length < 10 ? 'Add at least 10 characters of detail' : null;
      });
      return null;
    }
    return 'EcoTrack issue report\n\n$title\n\n$details';
  }

  Future<void> _copyReport() async {
    final String? report = _validatedReport();
    if (report == null) return;
    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) return;
    setState(() {
      _copied = true;
      _statusMessage = 'Report copied. Paste it into an email or chat.';
    });
  }

  void _showFailure(String message) {
    setState(() {
      _copied = false;
      _statusMessage = message;
    });
  }

  Future<void> _shareReport(BuildContext shareContext) async {
    final String? report = _validatedReport();
    if (report == null) return;
    final String title = _title.text.trim();

    try {
      final RenderObject? renderObject = shareContext.findRenderObject();
      final Rect? sharePositionOrigin =
          renderObject is RenderBox && renderObject.hasSize
              ? renderObject.localToGlobal(Offset.zero) & renderObject.size
              : null;
      final ShareResult result = await Share.shareWithResult(
        report,
        subject: 'EcoTrack issue report: $title',
        sharePositionOrigin: sharePositionOrigin,
      );
      if (!mounted) return;
      switch (result.status) {
        case ShareResultStatus.success:
          Navigator.pop(context);
          widget.store.toast('Report shared');
        case ShareResultStatus.dismissed:
          _showFailure('Sharing was cancelled. Try again or copy the report.');
        case ShareResultStatus.unavailable:
          _showFailure(
            'Sharing is not available in this browser. '
            'Copy the report instead.',
          );
      }
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showFailure(
        'Could not open the share sheet: ${error.message ?? error.code}',
      );
    } on MissingPluginException {
      if (!mounted) return;
      _showFailure('Sharing is unavailable on this device. Copy the report.');
    }
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
