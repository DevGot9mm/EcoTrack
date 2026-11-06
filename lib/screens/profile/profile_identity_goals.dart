part of '../profile_screen.dart';

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

