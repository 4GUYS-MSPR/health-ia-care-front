import 'package:flutter/material.dart';

import '../models/pagination_info.dart';


class PaginationControls extends StatelessWidget {
  const PaginationControls({
    super.key,
    required this.pagination,
    required this.onPrevious,
    required this.onNext,
  });

  final PaginationInfo pagination;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: pagination.hasPreviousPage ? onPrevious : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),

          // Page info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Page ${pagination.currentPage} of ${pagination.totalPages}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${pagination.offset + 1} - ${(pagination.offset + pagination.limit).clamp(0, pagination.count)} of ${pagination.count}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),

          // Next button
          ElevatedButton.icon(
            onPressed: pagination.hasNextPage ? onNext : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
