import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/iso_social_button.dart';
import '../widgets/sheets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final LevelInfo lvl = levelOf(store.points);
    final cs = Theme.of(context).colorScheme;

    return EcoScreen(
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
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
              StatTile(
                value: groupThousands(store.points),
                caption: 'Eco Points',
                valueSize: 17,
              ),
              Pressable(
                onTap: () => showEcoSheet(
                  context,
                  _BadgesSection(store: store),
                ),
                fillWidth: true,
                borderRadius: BorderRadius.circular(Eco.rCard),
                child: SizedBox(
                  width: double.infinity,
                  child: StatTile(
                    value:
                        '${store.unlockedBadgeCount}/${store.badges.length}',
                    caption: 'badges',
                    valueSize: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _GoalsSection(store: store),
          const SizedBox(height: 24),
          _SettingsSection(store: store),
          const SizedBox(height: 20),
          _SocialSection(store: store),
        ],
      ),
    );
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(store.playerName, style: F.d(17)),
                const SizedBox(height: 2),
                Text(
                  'Climate action since ${store.joined} · '
                  'Level ${level.idx + 1} ${level.name}',
                  style: F.b(12.5, wght: 600, color: cs.muted),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _GoalProgress(
                label: 'Weekly carbon goal',
                value: weekTotal,
                target: store.weeklyTarget,
                categories: store.catTotals(store.inRange(0, 6)),
              ),
              const SizedBox(height: 16),
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
  final Map<String, double> categories;

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
            Expanded(child: Text(label, style: F.b(14, wght: 700))),
            Text(targetText, style: F.b(13, wght: 800, color: cs.ink2)),
          ],
        ),
        const SizedBox(height: 8),
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
  final Map<String, double> categories;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final double fill = clampDouble(progress, 0, 1);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double filledWidth = constraints.maxWidth * fill;
        final List<String> categoriesInOrder =
            <String>['transport', 'electricity', 'food'];
        double left = 0;
        final List<Widget> segments = <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surface2,
                borderRadius: BorderRadius.circular(Eco.rPill),
              ),
            ),
          ),
          if (total > 0)
            for (final String category in categoriesInOrder)
              if ((categories[category] ?? 0) > 0)
                Builder(
                  builder: (BuildContext context) {
                    final double width =
                        filledWidth * (categories[category]! / total);
                    final Widget segment = Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      width: width,
                      child: ColoredBox(color: catOf(category).color),
                    );
                    left += width;
                    return segment;
                  },
                ),
        ];

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
            const SheetGrab(),
            const SizedBox(height: 8),
            const SheetTitle(title: 'Choose a profile picture'),
            const SizedBox(height: 16),
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
                        padding: const EdgeInsets.all(4),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Badges'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: store.badges.length,
          itemBuilder: (BuildContext context, int i) {
            final Badge b = store.badges[i];
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

  void _showBadgeDetail(BuildContext context, Badge b) {
    final cs = Theme.of(context).colorScheme;
    showEcoSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetGrab(),
          const SizedBox(height: 8),
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
          const SizedBox(height: 12),
          Text(
            b.name,
            style: F.d(18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            b.desc,
            style: F.b(13, height: 1.45, color: cs.muted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            b.unlocked ? 'Unlocked' : 'Locked',
            style:
                F.b(13, wght: 800, color: b.unlocked ? cs.leaf : cs.muted),
          ),
          const SizedBox(height: 12),
          EcoBar(
            value: b.progress / b.target,
            color: b.unlocked ? cs.leaf : cs.muted,
            height: 8,
          ),
          const SizedBox(height: 6),
          Text(
            '${b.progress.round()} of ${b.target.round()} complete',
            style: F.b(13, height: 1.45, color: cs.muted),
          ),
          const SizedBox(height: 14),
          EcoButton(
            label: 'Close',
            block: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatefulWidget {
  const _BadgeItem({required this.b, required this.cs, required this.onTap});

  final Badge b;
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
                hoverScale: 1.05,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.b.unlocked
                        ? widget.cs.surface
                        : widget.cs.surface2,
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
    final Badge b = widget.b;
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
        const SizedBox(height: 4),
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
    final Badge b = widget.b;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SectionHead(title: 'Account'),
        const SizedBox(height: 8),
        _SettingsRow(
          icon: 'target',
          label: 'Carbon target',
          trailing: '${fmt1(store.dailyTarget)} kg / day',
          onTap: () => _showTargetPicker(context, store),
        ),
        _SettingsRow(
          icon: 'tips',
          label: 'Tips',
          onTap: () => store.go('tips'),
        ),
        _SettingsRow(
          icon: 'shield',
          label: 'Account & security',
          onTap: () => _showAccountSettings(context, store),
        ),
        _SettingsRow(
          icon: 'settings',
          label: 'Units',
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
        const SizedBox(height: 4),
        Text(
          'Social account links are placeholders until official URLs are set.',
          style: F.b(12, color: cs.muted),
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
              hoverFace: const Color(0xFFE4405F),
              hoverLeft: const Color(0xFFD81C3F),
              hoverBottom: const Color(0xFFE46880),
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () => _openSocialLink(
                store,
                'Instagram',
                'https://www.instagram.com/',
              ),
            ),
            IsoSocialButton(
              icon: FontAwesomeIcons.tiktok,
              label: 'TikTok',
              hoverFace: const Color(0xFF111111),
              hoverLeft: const Color(0xFF2B2B2B),
              hoverBottom: const Color(0xFF414141),
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () =>
                  _openSocialLink(store, 'TikTok', 'https://www.tiktok.com/'),
            ),
            IsoSocialButton(
              icon: FontAwesomeIcons.xTwitter,
              label: 'X',
              hoverFace: const Color(0xFF111111),
              hoverLeft: const Color(0xFF2B2B2B),
              hoverBottom: const Color(0xFF414141),
              idleFace: cs.surface,
              idleSide: cs.lineStrong,
              idleContent: cs.ink,
              width: 145,
              height: 60,
              depth: 14,
              onTap: () => _openSocialLink(store, 'X', 'https://x.com/'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openSocialLink(
    EcoStore store,
    String platform,
    String url,
  ) async {
    final bool opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      store.toast('Could not open $platform.', Icons.error);
    }
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.danger = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                style: F.b(12, wght: 700, color: cs.muted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
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
            const SizedBox(height: 4),
            Text(
              'Pick the number you want EcoTrack to measure you against.',
              style: F.b(13, height: 1.45, color: cs.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...<double>[4, 6, 8].map((double value) {
              final bool selected = value == store.dailyTarget;
              return Pressable(
                onTap: () {
                  Navigator.pop(ctx);
                  store.setDailyTarget(value);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 8),
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
                              style: F.b(13, height: 1.45, color: cs.muted),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        EcoIcon('check', size: 20, color: cs.leaf),
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
  final TextEditingController name =
      TextEditingController(text: store.playerName);
  await showEcoSheet(
    context,
    Builder(
      builder: (BuildContext ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SheetTitle(title: 'Account & security'),
            const SizedBox(height: 6),
            Text(
              'This demo keeps a local profile only. You can update its display name here.',
              style: F.b(13, height: 1.45, color: cs.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 14),
            EcoButton(
              label: 'Save name',
              block: true,
              onPressed: () {
                if (name.text.trim().length < 2) {
                  store.toast('Enter at least two characters');
                  return;
                }
                store.setPlayerName(name.text);
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    ),
  );
  name.dispose();
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
            const SheetTitle(title: 'Distance units'),
            const SizedBox(height: 4),
            Text(
              'Used for transport activity input and history.',
              style: F.b(13, height: 1.45, color: cs.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
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
          ],
        );
      },
    ),
  );
}

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
        padding: const EdgeInsets.symmetric(vertical: 4),
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
    Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SheetTitle(title: 'Help & support'),
        const SizedBox(height: 14),
        _HelpItem(
          title: 'How are emissions estimated?',
          body:
              'Each activity uses an illustrative emissions factor. Your logged amounts are converted before the estimate is calculated.',
        ),
        _HelpItem(
          title: 'Where is my data stored?',
          body:
              'This demo keeps data in memory on this device session. It is not synced to an account or server.',
        ),
        const SizedBox(height: 12),
        EcoButton(
          label: 'Browse Eco Tips',
          leading: 'tips',
          block: true,
          onPressed: () {
            Navigator.pop(context);
            store.go('tips');
          },
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EcoCard(
        flat: true,
        background: cs.surface2,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: F.b(14, wght: 800)),
            const SizedBox(height: 4),
            Text(body, style: F.small.copyWith(color: cs.ink2)),
          ],
        ),
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
          children: <Widget>[
            const SheetTitle(title: 'About EcoTrack'),
            const SizedBox(height: 8),
            Text(
              'EcoTrack helps make everyday climate choices visible. Carbon figures are estimates for guidance, not audited measurements.',
              style: F.b(14.5, height: 1.5, color: cs.ink2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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

class SheetTitle extends StatelessWidget {
  const SheetTitle({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: F.d(20),
      textAlign: TextAlign.center,
    );
  }
}
