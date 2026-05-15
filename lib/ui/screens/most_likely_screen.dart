import 'dart:async';
import 'package:flutter/material.dart';
import 'package:o_arbitro/models/most_likely_prompt.dart';
import 'package:o_arbitro/models/session_state.dart';
import 'package:o_arbitro/ui/theme/app_colors.dart';
import 'package:o_arbitro/ui/theme/app_text_styles.dart';
import 'package:o_arbitro/ui/theme/app_spacing.dart';
import 'package:o_arbitro/ui/components/arbitro_button.dart';
import 'package:o_arbitro/ui/components/glass_card.dart';
import 'package:o_arbitro/ui/components/avatar_icon.dart';
import 'package:o_arbitro/services/haptic_service.dart';

enum GamePhase { prompt, voting, reveal, result }

class MostLikelyScreen extends StatefulWidget {
  const MostLikelyScreen({super.key});

  @override
  State<MostLikelyScreen> createState() => _MostLikelyScreenState();
}

class _MostLikelyScreenState extends State<MostLikelyScreen>
    with SingleTickerProviderStateMixin {
  late MostLikelyPrompt _prompt;
  final Map<String, String> _votes = {};
  GamePhase _phase = GamePhase.prompt;
  Timer? _timer;
  int _timeLeft = 30;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;
  Map<String, int> _voteCounts = {};
  String _winnerName = '';
  int _winnerVotes = 0;

  @override
  void initState() {
    super.initState();
    _prompt = MostLikelyPrompts.getRandom();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Cubic(0.23, 1, 0.32, 1),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _revealController.dispose();
    super.dispose();
  }

  void _startVoting() {
    setState(() {
      _phase = GamePhase.voting;
      _timeLeft = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timer?.cancel();
          _calculateResults();
        }
      });
    });
    HapticService.instance.turnAnnounce();
  }

  void _voteFor(String playerName) {
    if (_phase != GamePhase.voting) return;
    final state = SessionState.of(context);
    final currentPlayerName = state.session?.currentDareState?.player;
    if (currentPlayerName == null) return;

    setState(() {
      _votes[currentPlayerName] = playerName;
    });
    HapticService.instance.light();

    if (_votes.length >= (state.session?.players.length ?? 0)) {
      _timer?.cancel();
      _calculateResults();
    }
  }

  void _calculateResults() {
    _voteCounts = {};
    for (final vote in _votes.values) {
      _voteCounts[vote] = (_voteCounts[vote] ?? 0) + 1;
    }

    int maxVotes = 0;
    _voteCounts.forEach((name, count) {
      if (count > maxVotes) {
        maxVotes = count;
        _winnerName = name;
        _winnerVotes = count;
      }
    });

    setState(() {
      _phase = GamePhase.reveal;
    });
    _revealController.forward();
    HapticService.instance.celebration();
  }

  Widget _buildPromptPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'MAIS PROVÁVEL',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.pink,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _prompt.textPt,
                style: AppTextStyles.dareTextLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ArbitroButton(
          label: 'INICIAR VOTAÇÃO',
          onPressed: _startVoting,
          variant: ArbitroButtonVariant.primary,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildVotingPhase() {
    final state = SessionState.of(context);
    final session = state.session;
    if (session == null) return const SizedBox();

    return Column(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                _prompt.textPt,
                style: AppTextStyles.heading.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.timer,
                      color: _timeLeft <= 10 ? AppColors.danger : AppColors.gold,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$_timeLeft s',
                    style: AppTextStyles.score.copyWith(
                      color: _timeLeft <= 10 ? AppColors.danger : AppColors.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: session.players.length,
            itemBuilder: (context, index) {
              final player = session.players[index];
              final isVoted = _votes.values.contains(player.name);
              return GestureDetector(
                onTap: () => _voteFor(player.name),
                child: GlassCard(
                  variant: isVoted
                      ? GlassCardVariant.highlighted
                      : GlassCardVariant.defaultCard,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AvatarIcon(id: player.avatarId, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        player.name,
                        style: AppTextStyles.bodyStrong,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRevealPhase() {
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.scale(
              scale: 0.8 + (0.2 * _revealAnimation.value),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'RESULTADO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _winnerName,
                      style: AppTextStyles.heading.copyWith(color: AppColors.gold),
                    ),
                    Text(
                      '$_winnerVotes voto(s)',
                      style: AppTextStyles.body.copyWith(color: AppColors.textGold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ArbitroButton(
              label: 'CONTINUAR',
              onPressed: () {
                setState(() {
                  _phase = GamePhase.result;
                  _revealController.reset();
                });
              },
              variant: ArbitroButtonVariant.emerald,
              fullWidth: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultPhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.emoji_events, size: 64, color: AppColors.gold),
        const SizedBox(height: 16),
        Text(
          'PONTOS GANHOS!',
          style: AppTextStyles.display.copyWith(color: AppColors.gold),
        ),
        const SizedBox(height: 24),
        ArbitroButton(
          label: 'PRÓXIMO',
          onPressed: () {
            setState(() {
              _prompt = MostLikelyPrompts.getRandom();
              _votes.clear();
              _voteCounts.clear();
              _phase = GamePhase.prompt;
            });
          },
          variant: ArbitroButtonVariant.primary,
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        ArbitroButton(
          label: 'VOLTAR AO LOBBY',
          onPressed: () => Navigator.of(context).pop(),
          variant: ArbitroButtonVariant.ghost,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('MAIS PROVÁVEL', style: AppTextStyles.label),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientBgPattern,
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.screenPadding(context)),
          child: switch (_phase) {
            GamePhase.prompt => _buildPromptPhase(),
            GamePhase.voting => _buildVotingPhase(),
            GamePhase.reveal => _buildRevealPhase(),
            GamePhase.result => _buildResultPhase(),
          },
        ),
      ),
    );
  }
}
