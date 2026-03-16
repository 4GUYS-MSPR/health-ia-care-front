import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/gender.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/subscription.dart';

/// A data table widget for displaying members with sorting capabilities.
class MembersDataTable extends StatelessWidget {
  const MembersDataTable({
    super.key,
    required this.members,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onMemberTap,
    required this.onMemberEdit,
    required this.onMemberDelete,
    this.selectedMemberId,
    this.compact = false,
  });

  final List<Member> members;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Member member) onMemberTap;
  final void Function(Member member) onMemberEdit;
  final void Function(int memberId) onMemberDelete;
  final int? selectedMemberId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.sizeOf(context).width),
        child: SingleChildScrollView(
          child: DataTable(
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            showCheckboxColumn: false,
            horizontalMargin: compact ? 12 : 16,
            columnSpacing: compact ? 20 : 28,
            dataRowMinHeight: compact ? 44 : 52,
            dataRowMaxHeight: compact ? 56 : 64,
            headingRowColor: WidgetStatePropertyAll(
              context.colorScheme.surfaceContainerHighest.withAlpha(128),
            ),
            columns: _buildColumns(context, l10n),
            rows: _buildRows(context, l10n),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context, l10n) {
    return [
      DataColumn(
        label: Text(l10n.memberTableColumnId),
        numeric: true,
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      if (!compact)
        DataColumn(
          label: Text(l10n.memberTableColumnAge),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      DataColumn(
        label: Text(l10n.memberTableColumnGender),
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text(l10n.memberTableColumnLevel),
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      DataColumn(
        label: Text(l10n.memberTableColumnSubscription),
        onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
      ),
      if (!compact)
        DataColumn(
          label: Text(l10n.memberTableColumnBmi),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      if (!compact)
        DataColumn(
          label: Text(l10n.memberTableColumnWorkout),
          numeric: true,
          onSort: (columnIndex, ascending) => onSort(columnIndex, ascending),
        ),
      DataColumn(
        label: Text(l10n.memberTableColumnActions),
      ),
    ];
  }

  List<DataRow> _buildRows(BuildContext context, l10n) {
    return members.map((member) {
      final isSelected = selectedMemberId == member.id;

      return DataRow(
        selected: isSelected,
        color: isSelected
            ? WidgetStatePropertyAll(
                context.colorScheme.primaryContainer.withAlpha(64),
              )
            : null,
        onSelectChanged: (_) => onMemberTap(member),
        cells: [
          DataCell(Text('#${member.id}')),
          if (!compact)
            DataCell(
              Text(member.age?.toString() ?? '-'),
            ),
          DataCell(_buildGenderChip(context, member.gender, l10n)),
          DataCell(_buildLevelChip(context, member.level, l10n)),
          DataCell(_buildSubscriptionChip(context, member.subscription, l10n)),
          if (!compact) DataCell(Text(member.bmi.toStringAsFixed(1))),
          if (!compact) DataCell(Text('${member.workoutFrequency}x')),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  tooltip: l10n.memberTableViewTooltip,
                  onPressed: () => onMemberTap(member),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.memberFormEditTitle,
                  onPressed: () => onMemberEdit(member),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outlined,
                    size: 20,
                    color: context.colorScheme.error,
                  ),
                  tooltip: l10n.memberDeleteDialogConfirmButton,
                  onPressed: () => onMemberDelete(member.id),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildGenderChip(BuildContext context, Gender gender, l10n) {
    final (label, icon) = switch (gender) {
      Gender.male => (l10n.memberGenderMale, Icons.male),
      Gender.female => (l10n.memberGenderFemale, Icons.female),
      Gender.unknow => (l10n.memberGenderUnknown, Icons.person_outline),
    };

    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChip(BuildContext context, Level level, l10n) {
    final (label, color) = switch (level) {
      Level.beginner => (l10n.memberLevelBeginner, Colors.green),
      Level.intermediate => (l10n.memberLevelIntermediate, Colors.orange),
      Level.expert => (l10n.memberLevelExpert, Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubscriptionChip(
    BuildContext context,
    Subscription subscription,
    l10n,
  ) {
    final (label, color) = switch (subscription) {
      Subscription.free => (l10n.memberSubscriptionFree, Colors.grey),
      Subscription.premium => (l10n.memberSubscriptionPremium, Colors.amber),
      Subscription.premiumPlus => (l10n.memberSubscriptionPremiumPlus, Colors.purple),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
