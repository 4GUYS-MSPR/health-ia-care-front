import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../domain/entities/member.dart';
import '../widgets/members_data_table.dart';

/// Compact layout for members page - single column with data table.
class MembersCompactLayout extends StatelessWidget {
  const MembersCompactLayout({
    super.key,
    required this.members,
    required this.isLoading,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.onMemberSelected,
    required this.onMemberEdit,
    required this.onMemberDelete,
    required this.onAddMember,
    required this.onRefresh,
  });

  final List<Member> members;
  final bool isLoading;
  final int sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending) onSort;
  final void Function(Member member) onMemberSelected;
  final void Function(Member member) onMemberEdit;
  final void Function(int memberId) onMemberDelete;
  final VoidCallback onAddMember;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
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
                    compact: true,
                  ),
                if (isLoading) _buildLoadingOverlay(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            l10n.membersPageTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton.outlined(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: l10n.membersRefreshButton,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onAddMember,
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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAddMember,
            icon: const Icon(Icons.add),
            label: Text(l10n.membersAddButton),
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
