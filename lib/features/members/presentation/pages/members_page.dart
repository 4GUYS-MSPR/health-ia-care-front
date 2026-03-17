import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/shared/layouts/responsive_layout_builder.dart';
import '../../data/models/enum_item_model.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
import '../bloc/members_bloc.dart';
import '../layouts/members_compact_layout.dart';
import '../layouts/members_large_layout.dart';
import '../layouts/members_medium_layout.dart';
import '../widgets/member_delete_dialog.dart';
import '../widgets/member_error_banner.dart';
import '../widgets/member_form_dialog.dart';

/// Page displaying all members with CRUD functionality.
class MembersPage extends StatelessWidget {
  const MembersPage({
    super.key,
    required this.createBloc,
    required this.loadObjectiveOptions,
    required this.loadGenderOptions,
    required this.loadLevelOptions,
    required this.loadSubscriptionOptions,
  });

  final MembersBloc Function() createBloc;
  final Future<List<Objective>> Function() loadObjectiveOptions;
  final Future<List<EnumItemModel>> Function() loadGenderOptions;
  final Future<List<EnumItemModel>> Function() loadLevelOptions;
  final Future<List<EnumItemModel>> Function() loadSubscriptionOptions;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => createBloc()..add(const LoadMembersRequested()),
      child: _MembersPageContent(
        loadObjectiveOptions: loadObjectiveOptions,
        loadGenderOptions: loadGenderOptions,
        loadLevelOptions: loadLevelOptions,
        loadSubscriptionOptions: loadSubscriptionOptions,
      ),
    );
  }
}

class _MembersPageContent extends StatefulWidget {
  const _MembersPageContent({
    required this.loadObjectiveOptions,
    required this.loadGenderOptions,
    required this.loadLevelOptions,
    required this.loadSubscriptionOptions,
  });

  final Future<List<Objective>> Function() loadObjectiveOptions;
  final Future<List<EnumItemModel>> Function() loadGenderOptions;
  final Future<List<EnumItemModel>> Function() loadLevelOptions;
  final Future<List<EnumItemModel>> Function() loadSubscriptionOptions;

  @override
  State<_MembersPageContent> createState() => _MembersPageContentState();
}

class _MembersPageContentState extends State<_MembersPageContent> {
  // Sorting state
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  // Selection state
  Member? _selectedMember;
  bool _showCreateForm = false;
  late final Future<List<Objective>> _objectiveOptionsFuture;
  late final Future<List<EnumItemModel>> _genderOptionsFuture;
  late final Future<List<EnumItemModel>> _levelOptionsFuture;
  late final Future<List<EnumItemModel>> _subscriptionOptionsFuture;

  @override
  void initState() {
    super.initState();
    _objectiveOptionsFuture = widget.loadObjectiveOptions();
    _genderOptionsFuture = widget.loadGenderOptions();
    _levelOptionsFuture = widget.loadLevelOptions();
    _subscriptionOptionsFuture = widget.loadSubscriptionOptions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MembersBloc, MembersState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        final l10n = context.l10n;
        final members = _getMembersFromState(state);
        final isLoading = _isLoadingState(state);
        final sortedMembers = _sortMembers(members);
        final errorMessage = switch (state) {
          MembersError(:final failure) => failure.debugMessage ?? l10n.membersErrorLoading,
          _ => null,
        };

        return Column(
          children: [
            if (errorMessage != null)
              MemberErrorBanner(
                message: errorMessage,
                onRetry: _onRefresh,
              ),
            Expanded(
              child: ResponsiveLayoutBuilder(
                compact: MembersCompactLayout(
                  members: sortedMembers,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  onMemberSelected: _onMemberSelected,
                  onMemberEdit: _showEditDialog,
                  onMemberDelete: _showDeleteDialog,
                  onAddMember: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                ),
                medium: MembersMediumLayout(
                  members: sortedMembers,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  onSort: _onSort,
                  onMemberSelected: _onMemberSelected,
                  onMemberEdit: _showEditDialog,
                  onMemberDelete: _showDeleteDialog,
                  onAddMember: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                ),
                large: MembersLargeLayout(
                  members: sortedMembers,
                  selectedMember: _selectedMember,
                  isLoading: isLoading,
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  showCreateForm: _showCreateForm,
                  objectiveOptionsFuture: _objectiveOptionsFuture,
                  genderOptionsFuture: _genderOptionsFuture,
                  levelOptionsFuture: _levelOptionsFuture,
                  subscriptionOptionsFuture: _subscriptionOptionsFuture,
                  onSort: _onSort,
                  onMemberSelected: _onMemberSelected,
                  onMemberEdit: _showEditDialog,
                  onMemberDelete: _showDeleteDialog,
                  onAddMember: _showCreateDialog,
                  onImportExport: _onImportExport,
                  onRefresh: _onRefresh,
                  onCloseDetails: _onCloseDetails,
                  onToggleCreateForm: _onToggleCreateForm,
                  onMemberCreated: _onMemberCreated,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Member> _getMembersFromState(MembersState state) {
    return switch (state) {
      MembersLoaded(:final members) => members,
      MemberCreating(:final existingMembers) => existingMembers,
      MemberCreated(:final allMembers) => allMembers,
      MemberUpdating(:final existingMembers) => existingMembers,
      MemberUpdated(:final allMembers) => allMembers,
      MemberDeleting(:final existingMembers) => existingMembers,
      MemberDeleted(:final remainingMembers) => remainingMembers,
      _ => [],
    };
  }

  bool _isLoadingState(MembersState state) {
    return switch (state) {
      MembersInitial() || MembersLoading() => true,
      MemberCreating() || MemberUpdating() || MemberDeleting() => true,
      _ => false,
    };
  }

  List<Member> _sortMembers(List<Member> members) {
    final sortedList = List<Member>.from(members);

    sortedList.sort((a, b) {
      int comparison;

      switch (_sortColumnIndex) {
        case 0: // ID
          comparison = a.id.compareTo(b.id);
        case 1: // Age
          comparison = (a.age ?? 0).compareTo(b.age ?? 0);
        case 2: // Gender
          comparison = a.gender.index.compareTo(b.gender.index);
        case 3: // Level
          comparison = a.level.index.compareTo(b.level.index);
        case 4: // Subscription
          comparison = a.subscription.index.compareTo(b.subscription.index);
        case 5: // BMI
          comparison = a.bmi.compareTo(b.bmi);
        case 6: // Workout
          comparison = a.workoutFrequency.compareTo(b.workoutFrequency);
        default:
          comparison = a.id.compareTo(b.id);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _onMemberSelected(Member member) {
    setState(() {
      _selectedMember = member;
      _showCreateForm = false;
    });
  }

  void _onCloseDetails() {
    setState(() {
      _selectedMember = null;
    });
  }

  void _onToggleCreateForm() {
    setState(() {
      _showCreateForm = !_showCreateForm;
      if (_showCreateForm) {
        _selectedMember = null;
      }
    });
  }

  void _onMemberCreated() {
    setState(() {
      _showCreateForm = false;
    });
  }

  void _onRefresh() {
    context.read<MembersBloc>().add(const RefreshMembersRequested());
  }

  void _onImportExport() {
    context.pushNamed(AppRoutes.membersImport);
  }

  void _handleStateChanges(BuildContext context, MembersState state) {
    final l10n = context.l10n;

    switch (state) {
      case MemberCreated(:final member):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.memberSuccessCreated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Auto-select the newly created member on large layouts
        setState(() {
          _selectedMember = member;
          _showCreateForm = false;
        });
      case MemberUpdated(:final member):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.memberSuccessUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Update selected member if it was the one updated
        if (_selectedMember?.id == member.id) {
          setState(() {
            _selectedMember = member;
          });
        }
      case MemberDeleted():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.memberSuccessDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Clear selection if deleted member was selected
        setState(() {
          _selectedMember = null;
        });
      case MembersError(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.debugMessage ?? l10n.membersErrorLoading),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colorScheme.error,
          ),
        );
      default:
        break;
    }
  }

  Future<void> _showCreateDialog() async {
    final data = await MemberFormDialog.show(
      context,
      objectiveOptionsFuture: _objectiveOptionsFuture,
      genderOptionsFuture: _genderOptionsFuture,
      levelOptionsFuture: _levelOptionsFuture,
      subscriptionOptionsFuture: _subscriptionOptionsFuture,
    );
    if (data != null && mounted) {
      context.read<MembersBloc>().add(
        CreateMemberRequested(
          age: data.age,
          bmi: data.bmi,
          fatPercentage: data.fatPercentage,
          height: data.height,
          weight: data.weight,
          workoutFrequency: data.workoutFrequency,
          objectives: data.objectives,
          genderId: data.genderId,
          levelId: data.levelId,
          subscriptionId: data.subscriptionId,
        ),
      );
    }
  }

  Future<void> _showEditDialog(Member member) async {
    final data = await MemberFormDialog.show(
      context,
      member: member,
      objectiveOptionsFuture: _objectiveOptionsFuture,
      genderOptionsFuture: _genderOptionsFuture,
      levelOptionsFuture: _levelOptionsFuture,
      subscriptionOptionsFuture: _subscriptionOptionsFuture,
    );
    if (data != null && mounted) {
      context.read<MembersBloc>().add(
        UpdateMemberRequested(
          id: member.id,
          age: data.age,
          bmi: data.bmi,
          fatPercentage: data.fatPercentage,
          height: data.height,
          weight: data.weight,
          workoutFrequency: data.workoutFrequency,
          objectives: data.objectives,
          genderId: data.genderId,
          levelId: data.levelId,
          subscriptionId: data.subscriptionId,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(int memberId) async {
    final confirmed = await MemberDeleteDialog.show(context);
    if (confirmed && mounted) {
      context.read<MembersBloc>().add(
        DeleteMemberRequested(id: memberId),
      );
    }
  }
}
