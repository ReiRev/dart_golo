enum ScoringRule {
  chinese,
}

abstract class Rule {
  final ScoringRule scoringRule;
  final double komi;

  Rule({
    required this.scoringRule,
    required this.komi,
  });
}

class ChineseRule extends Rule {
  ChineseRule({
    super.komi = 6.5,
  }) : super(scoringRule: ScoringRule.chinese);
}
