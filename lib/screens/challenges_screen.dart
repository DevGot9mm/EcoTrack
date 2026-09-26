import 'package:flutter/material.dart';

import '../icons.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sheets.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final Challenge featured = store.challenges.firstWhere(
      (Challenge challenge) => challenge.featured,
      orElse: () => store.challenges.first,
    );
    final List<Challenge> weekly = store.challenges
        .where((Challenge challenge) => challenge.id != featured.id)
        .toList();
    final int completed = store.challenges
        .where(
            (Challenge challenge) => challenge.state != ChallengeState.active)
        .length;

    return EcoScreen(
      header: EcoTopBar(
        title: 'Challenges',
        right: _StreakPill(days: store.streak),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),
          _FeaturedChallengeCard(challenge: featured, store: store),
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: SectionHead(
              title: 'This week',
              action: Text(
                '$completed of ${store.challenges.length} complete',
                style: F.b(12, wght: 800, color: Eco.muted),
              ),
            ),
          ),
          ...weekly.map(
            (Challenge challenge) => _ChallengeCard(
              challenge: challenge,
              store: store,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Eco.amberTint,
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const EcoIcon('flame', size: 15, color: Eco.amberInk),
          const SizedBox(width: 5),
          Text('$days days', style: F.b(12, wght: 800, color: Eco.amberInk)),
        ],
      ),
    );
  }
}

class _FeaturedChallengeCard extends StatelessWidget {
  const _FeaturedChallengeCard({required this.challenge, required this.store});

  final Challenge challenge;
  final EcoStore store;

  @override
  Widget build(BuildContext context) {
    final bool done = challenge.state == ChallengeState.claimed;
    final bool claimable = challenge.state == ChallengeState.claimable;
    final String actionLabel = done
        ? 'Challenge complete'
        : claimable
            ? 'Claim ${challenge.reward} points'
            : 'Mark as done';

    return EcoCard(
      tone: EcoCardTone.dark,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MascotCrop(
                challenge.mascot,
                size: 54,
                radius: 17,
                background: Eco.sage,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "TODAY'S CHALLENGE",
                      style: F.b(10, wght: 800, color: const Color(0xBFFFFFFF)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.title,
                      style: F.d(18, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.why,
                      style: F.b(13, wght: 600, color: const Color(0xD9FFFFFF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${challenge.progress.round()} of ${challenge.target.round()} done',
                  style: F.b(12, wght: 800, color: const Color(0xD9FFFFFF)),
                ),
              ),
              Text(
                '+${challenge.reward} pts',
                style: F.b(13, wght: 800, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EcoBar(
            value: challenge.progress / challenge.target,
            color: Eco.sage,
            track: const Color(0x42FFFFFF),
            height: 6,
          ),
          const SizedBox(height: 14),
          EcoButton(
            label: actionLabel,
            leading: done
                ? 'check'
                : claimable
                    ? 'sparkles'
                    : 'check',
            tone: done ? EcoButtonTone.onDark : EcoButtonTone.amber,
            block: true,
            onPressed: done
                ? null
                : () {
                    if (claimable) {
                      store.claim(challenge.id);
                    } else {
                      store.challengeDone(challenge.id);
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.store});

  final Challenge challenge;
  final EcoStore store;

  Color _stateColor(ChallengeState state) {
    switch (state) {
      case ChallengeState.active:
        return Eco.forest;
      case ChallengeState.claimable:
        return Eco.amber;
      case ChallengeState.claimed:
        return Eco.muted;
    }
  }

  String _stateLabel(ChallengeState state) {
    switch (state) {
      case ChallengeState.active:
        return 'Active';
      case ChallengeState.claimable:
        return 'Claimable';
      case ChallengeState.claimed:
        return 'Claimed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color stateColor = _stateColor(challenge.state);
    final String stateLabel = _stateLabel(challenge.state);

    return Pressable(
      onTap: () => _showDetail(context),
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: challenge.state == ChallengeState.claimed
              ? Eco.surface2
              : Eco.surface,
          border: Border.all(
            color: challenge.state == ChallengeState.claimed
                ? Eco.line
                : stateColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(Eco.rCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              challenge.title,
                              style: F.d(16.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: stateColor,
                              borderRadius: BorderRadius.circular(Eco.rPill),
                            ),
                            child: Text(
                              stateLabel,
                              style: F.b(11, wght: 800, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        challenge.why,
                        style: F.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catOf(challenge.cat).tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: EcoIcon(challenge.featured ? 'sparkles' : 'flag',
                      size: 20, color: catOf(challenge.cat).ink),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: EcoBar(
                    value: challenge.progress / challenge.target,
                    color: stateColor,
                    height: 6,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${challenge.progress.round()} / ${challenge.target.round()}',
                  style: F.b(12, wght: 800, color: Eco.muted),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _StatePill(
                  label: '+${challenge.reward} pts',
                  background: Eco.amberTint,
                  foreground: Eco.amberInk,
                ),
                _actionButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton() {
    if (challenge.state == ChallengeState.claimed) {
      return const SizedBox.shrink();
    }
    if (challenge.state == ChallengeState.active) {
      return EcoButton(
        label: 'Done',
        tone: EcoButtonTone.primary,
        radius: Eco.rPill,
        minHeight: 38,
        onPressed: () => store.challengeDone(challenge.id),
      );
    }
    return EcoButton(
      label: 'Claim',
      tone: EcoButtonTone.amber,
      radius: Eco.rPill,
      minHeight: 38,
      onPressed: () => store.claim(challenge.id),
    );
  }

  void _showDetail(BuildContext context) {
    showEcoSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SheetGrab(),
          const SizedBox(height: 8),
          Text(
            challenge.title,
            style: F.d(20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            challenge.why,
            style: F.body2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _StatePill(
            label: _stateLabel(challenge.state),
            background: challenge.state == ChallengeState.claimed
                ? Eco.mint
                : Eco.amberTint,
            foreground: challenge.state == ChallengeState.claimed
                ? Eco.forestInk
                : Eco.amberInk,
          ),
          const SizedBox(height: 16),
          EcoButton(
            label: challenge.state == ChallengeState.claimed
                ? 'Close'
                : challenge.state == ChallengeState.active
                    ? 'Mark as done'
                    : 'Claim reward',
            tone: challenge.state == ChallengeState.claimed
                ? EcoButtonTone.ghost
                : challenge.state == ChallengeState.active
                    ? EcoButtonTone.primary
                    : EcoButtonTone.amber,
            block: true,
            onPressed: () {
              Navigator.pop(context);
              if (challenge.state == ChallengeState.active) {
                store.challengeDone(challenge.id);
              } else if (challenge.state == ChallengeState.claimable) {
                store.claim(challenge.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatePill extends StatelessWidget {
  const _StatePill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Eco.rPill),
      ),
      child: Text(
        label,
        style: F.b(13, wght: 800, color: foreground),
      ),
    );
  }
}
