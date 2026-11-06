part of '../profile_screen.dart';

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

