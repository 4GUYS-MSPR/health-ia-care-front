import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/logging/logger_mixin.dart';
import '../../domain/entities/member.dart';
import '../../domain/entities/objective.dart';
import '../../domain/usecases/create_member_usecase.dart';
import '../../domain/usecases/delete_member_usecase.dart';
import '../../domain/usecases/get_all_members_usecase.dart';
import '../../domain/usecases/update_member_usecase.dart';

part 'members_event.dart';
part 'members_state.dart';

/// Bloc responsible for managing member operations.
class MembersBloc extends Bloc<MembersEvent, MembersState> with LoggerMixin {
  final GetAllMembersUsecase getAllMembersUsecase;
  final CreateMemberUsecase createMemberUsecase;
  final UpdateMemberUsecase updateMemberUsecase;
  final DeleteMemberUsecase deleteMemberUsecase;

  MembersBloc({
    required this.getAllMembersUsecase,
    required this.createMemberUsecase,
    required this.updateMemberUsecase,
    required this.deleteMemberUsecase,
  }) : super(const MembersInitial()) {
    on<LoadMembersRequested>(_onLoadMembersRequested);
    on<RefreshMembersRequested>(_onRefreshMembersRequested);
    on<CreateMemberRequested>(_onCreateMemberRequested);
    on<UpdateMemberRequested>(_onUpdateMemberRequested);
    on<DeleteMemberRequested>(_onDeleteMemberRequested);
  }

  @override
  String get loggerName => 'Members.Presentation.MembersBloc';

  /// Gets the current members list from state if available.
  List<Member> get _currentMembers {
    final currentState = state;
    return switch (currentState) {
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

  Future<void> _onLoadMembersRequested(
    LoadMembersRequested event,
    Emitter<MembersState> emit,
  ) async {
    logger.finest('LoadMembersRequested received');
    emit(const MembersLoading());

    final result = await getAllMembersUsecase(const NoParams()).run();

    result.fold(
      (failure) {
        logger.warning('Failed to load members: $failure');
        emit(MembersError(failure: failure));
      },
      (members) {
        logger.fine('Loaded ${members.length} members');
        emit(MembersLoaded(members: members));
      },
    );
  }

  Future<void> _onRefreshMembersRequested(
    RefreshMembersRequested event,
    Emitter<MembersState> emit,
  ) async {
    logger.finest('RefreshMembersRequested received');

    // Keep showing current data while refreshing
    final currentMembers = _currentMembers;

    final result = await getAllMembersUsecase(const NoParams()).run();

    result.fold(
      (failure) {
        logger.warning('Failed to refresh members: $failure');
        // If we had data before, keep it and show error
        if (currentMembers.isNotEmpty) {
          emit(MembersLoaded(members: currentMembers));
        } else {
          emit(MembersError(failure: failure));
        }
      },
      (members) {
        logger.fine('Refreshed ${members.length} members');
        emit(MembersLoaded(members: members));
      },
    );
  }

  Future<void> _onCreateMemberRequested(
    CreateMemberRequested event,
    Emitter<MembersState> emit,
  ) async {
    logger.finest('CreateMemberRequested received');
    final currentMembers = _currentMembers;
    emit(MemberCreating(existingMembers: currentMembers));

    final result = await createMemberUsecase(
      CreateMemberUsecaseParams(
        age: event.age,
        bmi: event.bmi,
        fatPercentage: event.fatPercentage,
        height: event.height,
        weight: event.weight,
        workoutFrequency: event.workoutFrequency,
        objectives: event.objectives,
        genderId: event.genderId,
        levelId: event.levelId,
        subscriptionId: event.subscriptionId,
      ),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to create member: $failure');
        emit(MembersError(failure: failure));
      },
      (member) {
        logger.fine('Created member with id=${member.id}');
        final updatedMembers = [...currentMembers, member];
        emit(MemberCreated(member: member, allMembers: updatedMembers));
        // Transition to loaded state
        emit(MembersLoaded(members: updatedMembers));
      },
    );
  }

  Future<void> _onUpdateMemberRequested(
    UpdateMemberRequested event,
    Emitter<MembersState> emit,
  ) async {
    logger.finest('UpdateMemberRequested received for id=${event.id}');
    final currentMembers = _currentMembers;
    emit(MemberUpdating(existingMembers: currentMembers, updatingId: event.id));

    final result = await updateMemberUsecase(
      UpdateMemberUsecaseParams(
        id: event.id,
        age: event.age,
        bmi: event.bmi,
        fatPercentage: event.fatPercentage,
        height: event.height,
        weight: event.weight,
        workoutFrequency: event.workoutFrequency,
        objectives: event.objectives,
        genderId: event.genderId,
        levelId: event.levelId,
        subscriptionId: event.subscriptionId,
      ),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to update member ${event.id}: $failure');
        emit(MembersError(failure: failure));
      },
      (member) {
        logger.fine('Updated member ${event.id}');
        final updatedMembers = currentMembers.map((m) => m.id == member.id ? member : m).toList();
        emit(MemberUpdated(member: member, allMembers: updatedMembers));
        // Transition to loaded state
        emit(MembersLoaded(members: updatedMembers));
      },
    );
  }

  Future<void> _onDeleteMemberRequested(
    DeleteMemberRequested event,
    Emitter<MembersState> emit,
  ) async {
    logger.finest('DeleteMemberRequested received for id=${event.id}');
    final currentMembers = _currentMembers;
    emit(MemberDeleting(existingMembers: currentMembers, deletingId: event.id));

    final result = await deleteMemberUsecase(
      DeleteMemberUsecaseParams(id: event.id),
    ).run();

    result.fold(
      (failure) {
        logger.warning('Failed to delete member ${event.id}: $failure');
        emit(MembersError(failure: failure));
      },
      (_) {
        logger.fine('Deleted member ${event.id}');
        final remainingMembers = currentMembers.where((m) => m.id != event.id).toList();
        emit(
          MemberDeleted(
            deletedId: event.id,
            remainingMembers: remainingMembers,
          ),
        );
        // Transition to loaded state
        emit(MembersLoaded(members: remainingMembers));
      },
    );
  }
}
