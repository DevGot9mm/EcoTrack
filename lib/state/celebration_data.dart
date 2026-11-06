import '../models/models.dart';

sealed class CelebrationData {
  const CelebrationData();
}

final class PointsCelebration extends CelebrationData {
  const PointsCelebration({required this.amount, required this.reason});

  final int amount;
  final String reason;
}

final class BadgeUnlockCelebration extends CelebrationData {
  const BadgeUnlockCelebration({required this.badge});

  final Achievement badge;
}

final class LevelUpCelebration extends CelebrationData {
  const LevelUpCelebration({required this.name, required this.idx});

  final String name;
  final int idx;
}

final class ChallengeCompleteCelebration extends CelebrationData {
  const ChallengeCompleteCelebration({
    required this.title,
    required this.points,
  });

  final String title;
  final int points;
}
