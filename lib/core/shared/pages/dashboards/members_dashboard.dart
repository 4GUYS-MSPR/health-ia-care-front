import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../features/members/domain/entities/gender.dart';
import '../../../../features/members/domain/entities/level.dart';
import '../../../../features/members/domain/entities/member.dart';
import '../../../../features/members/domain/entities/subscription.dart';
import '../../../../features/members/presentation/bloc/members_bloc.dart';
import '../../../extensions/l10n_extension.dart';
import '../../widgets/dashboard/generic_bar_chart.dart';
import '../../widgets/dashboard/generic_pie_chart.dart';
import '../../widgets/dashboard/graph_card.dart';
import '../../widgets/dashboard/legend_item.dart';

class MembersDashboard extends StatelessWidget {
  const MembersDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MembersBloc>()..add(const LoadMembersRequested()),
      child: BlocBuilder<MembersBloc, MembersState>(
        builder: (context, state) {
          if (state is MembersInitial || state is MembersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MembersError) {
            debugPrint(
              'MembersError in MembersDashboard: ${state.failure.debugMessage ?? 'no debug message'}',
            );
            return Center(child: Text(context.l10n.membersErrorLoading));
          }

          return _MembersContent(members: _extractMembers(state));
        },
      ),
    );
  }

  List<Member> _extractMembers(MembersState state) => switch (state) {
    MembersLoaded(:final members) => members,
    MemberCreating(:final existingMembers) => existingMembers,
    MemberCreated(:final allMembers) => allMembers,
    MemberUpdating(:final existingMembers) => existingMembers,
    MemberUpdated(:final allMembers) => allMembers,
    MemberDeleting(:final existingMembers) => existingMembers,
    MemberDeleted(:final remainingMembers) => remainingMembers,
    _ => <Member>[],
  };
}

class _MembersContent extends StatelessWidget {
  const _MembersContent({required this.members});

  final List<Member> members;

  static const _colors = [
    Colors.blue,
    Colors.pink,
    Colors.grey,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.amber,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.membersPageTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${members.length} ${context.l10n.memberStatsTotal}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildKpiCards(context),
          const SizedBox(height: 32),
          _buildResponsiveRow(
            context,
            _buildGenderDistribution(context),
            _buildLevelDistribution(context),
          ),
          const SizedBox(height: 16),
          _buildResponsiveRow(
            context,
            _buildSubscriptionDistribution(context),
            _buildObjectivesDistribution(context),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveRow(BuildContext context, Widget left, Widget right) => LayoutBuilder(
    builder: (layoutContext, constraints) => constraints.maxWidth > 700
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          )
        : Column(children: [left, const SizedBox(height: 16), right]),
  );

  Widget _buildKpiCards(BuildContext context) {
    final ageValues = members.where((member) => member.age != null).map((member) => member.age!);
    final averageAge = ageValues.isEmpty
        ? 0
        : ageValues.reduce((first, second) => first + second) / ageValues.length;

    final kpiCards = [
      _kpiCard(
        Icons.people,
        context.l10n.memberStatsTotal,
        '${members.length}',
        Colors.blue,
      ),
      _kpiCard(
        Icons.monitor_weight_outlined,
        context.l10n.memberStatsAvgBmi,
        _averageForMembers((member) => member.bmi).toStringAsFixed(1),
        Colors.indigo,
      ),
      _kpiCard(
        Icons.fitness_center,
        context.l10n.memberStatsAvgWorkout,
        '${_averageForMembers((member) => member.workoutFrequency.toDouble()).toStringAsFixed(1)}x',
        Colors.orange,
      ),
      _kpiCard(
        Icons.cake_outlined,
        context.l10n.memberCardAge,
        averageAge.toStringAsFixed(0),
        Colors.green,
      ),
      _kpiCard(
        Icons.water_drop_outlined,
        context.l10n.memberCardFatPercentage,
        '${_averageForMembers((member) => member.fatPercentage).toStringAsFixed(1)}%',
        Colors.red,
      ),
    ];

    return LayoutBuilder(
      builder: (layoutContext, constraints) {
        const spacing = 16.0;
        final crossAxisCount = constraints.maxWidth >= 1400
            ? 5
            : constraints.maxWidth >= 1000
            ? 3
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in kpiCards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  Widget _kpiCard(IconData icon, String label, String value, Color color) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildGenderDistribution(BuildContext context) {
    final labels = [
      context.l10n.memberGenderMale,
      context.l10n.memberGenderFemale,
      context.l10n.memberGenderUnknown,
    ];
    final values = [
      members.where((member) => member.gender == Gender.male).length.toDouble(),
      members.where((member) => member.gender == Gender.female).length.toDouble(),
      members.where((member) => member.gender == Gender.unknow).length.toDouble(),
    ];

    return GraphCard(
      title: context.l10n.memberStatsGenderDistribution,
      child: members.isEmpty
          ? Center(child: Text(context.l10n.membersEmptyState))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(values: values, labels: labels, colors: _colors),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < labels.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: LegendItem(
                          _colors[index % _colors.length],
                          '${labels[index]}: ${values[index].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLevelDistribution(BuildContext context) {
    final labels = [
      context.l10n.memberLevelBeginner,
      context.l10n.memberLevelIntermediate,
      context.l10n.memberLevelExpert,
    ];
    final values = [
      members.where((member) => member.level == Level.beginner).length.toDouble(),
      members.where((member) => member.level == Level.intermediate).length.toDouble(),
      members.where((member) => member.level == Level.expert).length.toDouble(),
    ];

    return GraphCard(
      title: context.l10n.memberStatsLevelDistribution,
      child: members.isEmpty
          ? Center(child: Text(context.l10n.membersEmptyState))
          : GenericBarChart(labels: labels, values: values, colors: _colors),
    );
  }

  Widget _buildSubscriptionDistribution(BuildContext context) {
    final labels = [
      context.l10n.memberSubscriptionFree,
      context.l10n.memberSubscriptionPremium,
      context.l10n.memberSubscriptionPremiumPlus,
    ];
    final values = [
      members.where((member) => member.subscription == Subscription.free).length.toDouble(),
      members.where((member) => member.subscription == Subscription.premium).length.toDouble(),
      members.where((member) => member.subscription == Subscription.premiumPlus).length.toDouble(),
    ];

    return GraphCard(
      title: context.l10n.memberStatsSubscriptionDistribution,
      child: members.isEmpty
          ? Center(child: Text(context.l10n.membersEmptyState))
          : Row(
              children: [
                Expanded(
                  child: GenericPieChart(values: values, labels: labels, colors: _colors),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int index = 0; index < labels.length; index++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: LegendItem(
                          _colors[index % _colors.length],
                          '${labels[index]}: ${values[index].toStringAsFixed(0)}',
                        ),
                      ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildObjectivesDistribution(BuildContext context) {
    final objectiveCount = <String, int>{};
    for (final member in members) {
      for (final objective in member.objectives) {
        final key = objective.description.trim();
        if (key.isEmpty) {
          continue;
        }
        objectiveCount[key] = (objectiveCount[key] ?? 0) + 1;
      }
    }

    final entries = objectiveCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = entries.take(7).toList();
    final labels = topEntries.map((entry) => entry.key).toList();
    final values = topEntries.map((entry) => entry.value.toDouble()).toList();

    return GraphCard(
      title: context.l10n.memberCardObjectives,
      child: topEntries.isEmpty
          ? Center(child: Text(context.l10n.memberDetailsNoObjectives))
          : GenericBarChart(labels: labels, values: values, colors: _colors),
    );
  }

  double _averageForMembers(double Function(Member member) selector) {
    if (members.isEmpty) {
      return 0;
    }
    final total = members.fold<double>(0, (sum, member) => sum + selector(member));
    return total / members.length;
  }
}
