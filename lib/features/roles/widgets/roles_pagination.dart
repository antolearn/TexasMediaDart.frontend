import 'package:flutter/material.dart';

import '../controllers/roles_controller.dart';

class RolesPagination extends StatelessWidget {
  const RolesPagination({super.key, required this.controller});

  final RolesController controller;

  @override
  Widget build(BuildContext context) {
    final firstItem = controller.totalCount == 0
        ? 0
        : ((controller.pageNumber - 1) * controller.pageSize) + 1;

    final calculatedLastItem = controller.pageNumber * controller.pageSize;

    final lastItem = calculatedLastItem > controller.totalCount
        ? controller.totalCount
        : calculatedLastItem;

    final hasMultiplePages = controller.totalPages > 1;

    final recordText = hasMultiplePages
        ? 'Showing $firstItem-$lastItem of ${controller.totalCount}'
        : '${controller.totalCount} '
              '${controller.totalCount == 1 ? 'record' : 'records'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(recordText, style: const TextStyle(fontWeight: FontWeight.w500)),

          if (hasMultiplePages) ...[
            const Spacer(),

            // First page
            IconButton(
              tooltip: 'First page',
              onPressed: controller.hasPreviousPage && !controller.isLoading
                  ? controller.firstPage
                  : null,
              icon: const Icon(Icons.first_page),
            ),

            // Previous page
            IconButton(
              tooltip: 'Previous page',
              onPressed: controller.hasPreviousPage && !controller.isLoading
                  ? controller.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Page ${controller.pageNumber} '
                'of ${controller.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),

            // Next page
            IconButton(
              tooltip: 'Next page',
              onPressed: controller.hasNextPage && !controller.isLoading
                  ? controller.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),

            // Last page
            IconButton(
              tooltip: 'Last page',
              onPressed: controller.hasNextPage && !controller.isLoading
                  ? controller.lastPage
                  : null,
              icon: const Icon(Icons.last_page),
            ),
          ],
        ],
      ),
    );
  }
}
