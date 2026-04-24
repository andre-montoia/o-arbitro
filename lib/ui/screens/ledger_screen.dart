import 'package:flutter/material.dart';
import '../../models/ledger_entry.dart';
import '../../models/session.dart';
import '../../models/session_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../components/glass_card.dart';
import '../components/arbitro_button.dart';
import '../components/new_ledger_entry_sheet.dart';

// Duration for the slide-in animation when a new entry is added
const _kEntryAnimDuration = Duration(milliseconds: 400);

enum _Filter { todos, apostas, previsoes, pontuacao }

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  _Filter _filter = _Filter.todos;
  final _listKey = GlobalKey<AnimatedListState>();
  int _prevEntryCount = 0;

  void _showNewEntry(BuildContext context) {
    final sessionState = SessionState.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.modalRadius),
        ),
      ),
      builder: (_) => SessionState(
        session: sessionState.session,
        onSessionChanged: sessionState.onSessionChanged,
        child: const NewLedgerEntrySheet(),
      ),
    );
  }

  List<LedgerEntry> _filtered(List<LedgerEntry> entries) {
    return switch (_filter) {
      _Filter.todos => entries,
      _Filter.apostas => entries.whereType<SocialBet>().toList(),
      _Filter.previsoes => entries.whereType<Prediction>().toList(),
      _Filter.pontuacao => entries.whereType<ScoreEntry>().toList(),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = SessionState.of(context);
    final count = state.session?.ledgerEntries.length ?? 0;
    if (count > _prevEntryCount && _prevEntryCount > 0) {
      _listKey.currentState?.insertItem(0, duration: _kEntryAnimDuration);
    }
    _prevEntryCount = count;
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final entries = state.session!.ledgerEntries.reversed.toList();
    final filtered = _filtered(entries);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  Text('Absurdity Ledger', style: AppTextStyles.heading),
                  const SizedBox(height: AppSpacing.lg),
                  _Leaderboard(session: state.session!),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'TODOS',
                          selected: _filter == _Filter.todos,
                          onTap: () => setState(() => _filter = _Filter.todos),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'APOSTAS',
                          selected: _filter == _Filter.apostas,
                          onTap: () =>
                              setState(() => _filter = _Filter.apostas),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'PREVISÕES',
                          selected: _filter == _Filter.previsoes,
                          onTap: () =>
                              setState(() => _filter = _Filter.previsoes),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'PONTUAÇÃO',
                          selected: _filter == _Filter.pontuacao,
                          onTap: () =>
                              setState(() => _filter = _Filter.pontuacao),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Sem entradas ainda', style: AppTextStyles.body))
                  : AnimatedList(
                      key: _listKey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding),
                      initialItemCount: filtered.length,
                      itemBuilder: (ctx, i, animation) {
                        if (i >= filtered.length) return const SizedBox.shrink();
                        final entry = filtered[i];
                        final globalIndex =
                            state.session!.ledgerEntries.indexOf(entry);
                        return _AnimatedEntryCard(
                          entry: entry,
                          index: globalIndex,
                          animation: animation,
                          isFirst: i == 0,
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ArbitroButton(
                label: '+ NOVA ENTRADA',
                onPressed: () => _showNewEntry(context),
                variant: ArbitroButtonVariant.secondary,
                fullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    final sorted = [...session.players]
      ..sort((a, b) => b.daresCompleted.compareTo(a.daresCompleted));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classificação', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          ...sorted.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  children: [
                    Text(p.name, style: AppTextStyles.bodyStrong),
                    const Spacer(),
                    Text('${p.daresCompleted} desafios',
                        style: AppTextStyles.caption),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.purple : AppColors.surface2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.purpleLight : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      );
}

class _AnimatedEntryCard extends StatelessWidget {
  const _AnimatedEntryCard({
    required this.entry,
    required this.index,
    required this.animation,
    required this.isFirst,
  });
  final LedgerEntry entry;
  final int index;
  final Animation<double> animation;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return Column(
      children: [
        SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: animation,
            child: _EntryCard(entry: entry, index: index),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry, required this.index});
  final LedgerEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return switch (entry) {
      SocialBet e => _BetCard(bet: e, index: index),
      Prediction e => _PredictionCard(prediction: e, index: index),
      ScoreEntry e => _ScoreCard(score: e),
    };
  }
}

class _BetCard extends StatefulWidget {
  const _BetCard({required this.bet, required this.index});
  final SocialBet bet;
  final int index;

  @override
  State<_BetCard> createState() => _BetCardState();
}

class _BetCardState extends State<_BetCard> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnim = Tween<double>(begin: 0.2, end: 1.0).animate(_pulse);
    if (widget.bet.status == BetStatus.pending) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_BetCard old) {
    super.didUpdateWidget(old);
    if (widget.bet.status == BetStatus.pending && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (widget.bet.status != BetStatus.pending && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();
    final isPending = widget.bet.status == BetStatus.pending;

    Widget card = GlassCard(
      variant: widget.bet.status == BetStatus.resolved
          ? GlassCardVariant.defaultCard
          : GlassCardVariant.highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🎲', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Text('APOSTA', style: AppTextStyles.label),
            const Spacer(),
            Text(
              widget.bet.status == BetStatus.pending ? 'PENDENTE' : 'RESOLVIDA',
              style: AppTextStyles.label.copyWith(
                color: widget.bet.status == BetStatus.pending
                    ? AppColors.gold
                    : AppColors.success,
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(widget.bet.description, style: AppTextStyles.bodyStrong),
          Text('Consequência: ${widget.bet.consequence}', style: AppTextStyles.body),
          if (widget.bet.loser != null)
            Text('Perdedor: ${widget.bet.loser}',
                style: AppTextStyles.body.copyWith(color: AppColors.danger)),
          if (widget.bet.status == BetStatus.pending) ...[
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              hint: Text('Escolher perdedor', style: AppTextStyles.caption),
              dropdownColor: AppColors.surface2,
              style: AppTextStyles.bodyStrong,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface2,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              items: players
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (loser) {
                if (loser == null) return;
                state.updateLedgerEntry(widget.index, widget.bet.resolve(loser));
              },
            ),
          ],
        ],
      ),
    );

    if (!isPending) return card;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius + 1),
          border: Border.all(
            color: AppColors.gold.withOpacity(_pulseAnim.value * 0.6),
            width: 1.5,
          ),
        ),
        child: child,
      ),
      child: card,
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.prediction, required this.index});
  final Prediction prediction;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = SessionState.of(context);
    final players = state.session!.players.map((p) => p.name).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🔮', style: TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.sm),
            Text('PREVISÃO', style: AppTextStyles.label),
            const Spacer(),
            if (prediction.resolved)
              Text('RESOLVIDA',
                  style:
                      AppTextStyles.label.copyWith(color: AppColors.success)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(prediction.description, style: AppTextStyles.bodyStrong),
          Text('Consequência: ${prediction.consequence}',
              style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          if (!prediction.resolved) ...[
            Text('Votos:', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            ...players.map((p) {
              final vote = prediction.votes[p];
              return Row(children: [
                Text(p, style: AppTextStyles.body),
                const Spacer(),
                GestureDetector(
                  onTap: () => state.updateLedgerEntry(
                      index, prediction.withVote(p, true)),
                  child: Icon(Icons.thumb_up_rounded,
                      color: vote == true
                          ? AppColors.success
                          : AppColors.textDisabled,
                      size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => state.updateLedgerEntry(
                      index, prediction.withVote(p, false)),
                  child: Icon(Icons.thumb_down_rounded,
                      color: vote == false
                          ? AppColors.danger
                          : AppColors.textDisabled,
                      size: 20),
                ),
              ]);
            }),
            if (prediction.votes.length == players.length) ...[
              const SizedBox(height: AppSpacing.sm),
              ArbitroButton(
                label: 'RESOLVER',
                onPressed: () =>
                    state.updateLedgerEntry(index, prediction.resolve()),
                variant: ArbitroButtonVariant.secondary,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score});
  final ScoreEntry score;

  String get _sourceIcon => switch (score.source) {
        ScoreSource.slots => '🎰',
        ScoreSource.roulette => '🎡',
        ScoreSource.manual => '✏️',
      };

  @override
  Widget build(BuildContext context) => GlassCard(
        child: Row(
          children: [
            Text(_sourceIcon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(score.player, style: AppTextStyles.bodyStrong),
                  Text(score.description, style: AppTextStyles.caption),
                ],
              ),
            ),
            Text('+1',
                style:
                    AppTextStyles.heading.copyWith(color: AppColors.success)),
          ],
        ),
      );
}
