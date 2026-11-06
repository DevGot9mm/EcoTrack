part of '../profile_screen.dart';

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

