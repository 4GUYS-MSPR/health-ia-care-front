import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../data/models/enum_item_model.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
import '../widgets/member_details_panel.dart';
import '../widgets/member_form_panel.dart';
import '../widgets/member_stats_card.dart';
import '../widgets/members_data_table.dart';

/// Large layout for members page - multi-pane with table, details, and stats.
class MembersLargeLayout extends StatelessWidget {
  const MembersLargeLayout({
    super.key,
    required this.members,
    required this.selectedMember,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.showCreateForm,
    required this.onSort,
    required this.onMemberSelected,
    required this.onMemberEdit,
    required this.onMemberDelete,
    required this.onAddMember,
    required this.onRefresh,
    required this.onCloseDetails,
    required this.onToggleCreateForm,
    required this.onMemberCreated,
    required this.objectiveOptionsFuture,
    required this.genderOptionsFuture,
    required this.levelOptionsFuture,
    required this.subscriptionOptionsFuture,
  });

  final List<Member> members;
  final Member? selectedMember;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final bool showCreateForm;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Member member) onMemberSelected;
  final void Function(Member member) onMemberEdit;
  final void Function(int memberId) onMemberDelete;
  final VoidCallback onAddMember;
  final VoidCallback onRefresh;
  final VoidCallback onCloseDetails;
  final VoidCallback onToggleCreateForm;
  final VoidCallback onMemberCreated;
  final Future<List<Objective>> objectiveOptionsFuture;
  final Future<List<EnumItemModel>> genderOptionsFuture;
  final Future<List<EnumItemModel>> levelOptionsFuture;
  final Future<List<EnumItemModel>> subscriptionOptionsFuture;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main content - Data table
        Expanded(
          flex: 3,
          child: _buildMainContent(context),
        ),
        const SizedBox(width: 24),
        // Side panel - Details or Create form or Stats
        Expanded(
          flex: 2,
          child: _buildSidePanel(context),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            _buildHeader(context, l10n),
            const Divider(height: 1),
            Expanded(
              child: Stack(
                children: [
                  if (members.isEmpty)
                    _buildEmptyState(context, l10n)
                  else
                    MembersDataTable(
                      members: members,
                      sortColumnIndex: sortColumnIndex,
                      sortAscending: sortAscending,
                      onSort: onSort,
                      onMemberTap: onMemberSelected,
                      onMemberEdit: onMemberEdit,
                      onMemberDelete: onMemberDelete,
                      selectedMemberId: selectedMember?.id,
                    ),
                  if (isLoading) _buildLoadingOverlay(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context) {
    final l10n = context.l10n;

    if (showCreateForm) {
      return MemberFormPanel(
        onCancel: onToggleCreateForm,
        onSaved: onMemberCreated,
        objectiveOptionsFuture: objectiveOptionsFuture,
        genderOptionsFuture: genderOptionsFuture,
        levelOptionsFuture: levelOptionsFuture,
        subscriptionOptionsFuture: subscriptionOptionsFuture,
      );
    }

    if (selectedMember != null) {
      return MemberDetailsPanel(
        member: selectedMember!,
        onClose: onCloseDetails,
        onEdit: () => onMemberEdit(selectedMember!),
        onDelete: () => onMemberDelete(selectedMember!.id),
      );
    }

    // Default: Show stats overview
    return Column(
      children: [
        MemberStatsCard(members: members),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.memberFormCreateTitle,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.membersEmptyStateDescription,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onToggleCreateForm,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.membersAddButton),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            l10n.membersPageTitle,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          if (members.isNotEmpty)
            Chip(
              label: Text('${members.length}'),
              visualDensity: VisualDensity.compact,
            ),
          const Spacer(),
          IconButton.outlined(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.membersRefreshButton,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onToggleCreateForm,
            icon: const Icon(Icons.add),
            label: Text(l10n.membersAddButton),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.membersEmptyState,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.membersEmptyStateDescription,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: context.colorScheme.surface.withAlpha(128),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
