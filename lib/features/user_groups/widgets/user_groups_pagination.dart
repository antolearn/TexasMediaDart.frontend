import 'package:flutter/material.dart';

import '../controllers/user_groups_controller.dart';

class UserGroupsPagination extends StatelessWidget {
  const UserGroupsPagination({super.key, required this.controller});

  final UserGroupsController controller;

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

          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Rows per page:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: controller.pageSize,
                items: UserGroupsController.allowedPageSizes
                    .map(
                      (pageSize) => DropdownMenuItem<int>(
                        value: pageSize,
                        child: Text('$pageSize'),
                      ),
                    )
                    .toList(),
                onChanged: controller.isLoading
                    ? null
                    : (pageSize) {
                        if (pageSize != null) {
                          controller.changePageSize(pageSize);
                        }
                      },
              ),
            ],
          ),

          if (hasMultiplePages) ...[
            const SizedBox(width: 24),

            IconButton(
              tooltip: 'First page',
              onPressed: controller.hasPreviousPage && !controller.isLoading
                  ? controller.firstPage
                  : null,
              icon: const Icon(Icons.first_page),
            ),

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

            IconButton(
              tooltip: 'Next page',
              onPressed: controller.hasNextPage && !controller.isLoading
                  ? controller.nextPage
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),

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
