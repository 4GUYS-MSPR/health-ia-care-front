class PaginationInfo {
  final int count;
  final String? nextUrl;
  final String? previousUrl;
  final int offset;
  final int limit;

  int get currentPage => (offset ~/ limit) + 1;
  int get totalPages => (count + limit - 1) ~/ limit;
  bool get hasNextPage => nextUrl != null;
  bool get hasPreviousPage => previousUrl != null;

  const PaginationInfo({
    required this.count,
    this.nextUrl,
    this.previousUrl,
    required this.offset,
    required this.limit,
  });

  // Constructeur pour l'état initial
  factory PaginationInfo.initial(int limit) => PaginationInfo(count: 0, nextUrl: null, previousUrl: null, offset: 0, limit: limit);

  // Création depuis une réponse JSON
  factory PaginationInfo.fromResponse(Map<String, dynamic> json, int offset, int limit) => PaginationInfo(
    count: json['count'] as int? ?? 0,
    nextUrl: json['next'] as String?,
    previousUrl: json['previous'] as String?,
    offset: offset,
    limit: limit,
  );

  @override
  String toString() => 'PaginationInfo(page: $currentPage/$totalPages, offset: $offset, limit: $limit, count: $count)';
}
