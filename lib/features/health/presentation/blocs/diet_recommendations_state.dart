part of 'diet_recommendations_bloc.dart';

sealed class DietRecommendationsState extends Equatable {
  const DietRecommendationsState();

  @override
  List<Object?> get props => [];
}

final class DietRecommendationsInitial extends DietRecommendationsState {
  const DietRecommendationsInitial();
}

final class DietRecommendationsLoading extends DietRecommendationsState {
  const DietRecommendationsLoading();
}

final class DietRecommendationsLoaded extends DietRecommendationsState {
  final List<DietRecommendation> items;
  final PaginationInfo? pagination;

  const DietRecommendationsLoaded({required this.items, this.pagination});

  @override
  List<Object?> get props => [items, pagination];
}

final class DietRecommendationsError extends DietRecommendationsState {
  final Failure failure;
  const DietRecommendationsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

final class DietRecommendationCreating extends DietRecommendationsState {
  final List<DietRecommendation> existingItems;

  const DietRecommendationCreating({required this.existingItems});

  @override
  List<Object?> get props => [existingItems];
}

final class DietRecommendationCreated extends DietRecommendationsState {
  final DietRecommendation item;
  final List<DietRecommendation> allItems;

  const DietRecommendationCreated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class DietRecommendationUpdating extends DietRecommendationsState {
  final List<DietRecommendation> existingItems;
  final int updatingId;

  const DietRecommendationUpdating({required this.existingItems, required this.updatingId});

  @override
  List<Object?> get props => [existingItems, updatingId];
}

final class DietRecommendationUpdated extends DietRecommendationsState {
  final DietRecommendation item;
  final List<DietRecommendation> allItems;

  const DietRecommendationUpdated({required this.item, required this.allItems});

  @override
  List<Object?> get props => [item, allItems];
}

final class DietRecommendationDeleting extends DietRecommendationsState {
  final List<DietRecommendation> existingItems;
  final int deletingId;

  const DietRecommendationDeleting({required this.existingItems, required this.deletingId});

  @override
  List<Object?> get props => [existingItems, deletingId];
}

final class DietRecommendationDeleted extends DietRecommendationsState {
  final int deletedId;
  final List<DietRecommendation> remainingItems;

  const DietRecommendationDeleted({required this.deletedId, required this.remainingItems});

  @override
  List<Object?> get props => [deletedId, remainingItems];
}
