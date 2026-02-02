import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/datasources/local/sync_service.dart';

/// Widget to display sync status indicator
class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final syncService = Get.find<SyncService>();
      
      return Obx(() {
        final isOnline = syncService.isOnline.value;
        final isSyncing = syncService.isSyncing.value;
        final pendingCount = syncService.pendingSyncCount.value;

        return Tooltip(
          message: _getTooltipMessage(isOnline, isSyncing, pendingCount),
          child: InkWell(
            onTap: () => _showSyncStatus(context, syncService),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSyncing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 20,
                      color: isOnline ? AppColors.success : AppColors.textTertiary,
                    ),
                  if (pendingCount > 0 && !isSyncing) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        pendingCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      });
    } catch (e) {
      // SyncService not available
      return const Icon(
        Icons.cloud_off,
        size: 20,
        color: AppColors.textTertiary,
      );
    }
  }

  String _getTooltipMessage(bool isOnline, bool isSyncing, int pendingCount) {
    if (isSyncing) return 'Syncing...';
    if (!isOnline) return 'Offline - $pendingCount pending';
    if (pendingCount > 0) return '$pendingCount items pending sync';
    return 'All synced';
  }

  void _showSyncStatus(BuildContext context, SyncService syncService) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sync Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _buildStatusRow(
              icon: syncService.isOnline.value ? Icons.wifi : Icons.wifi_off,
              label: 'Connection',
              value: syncService.isOnline.value ? 'Online' : 'Offline',
              color: syncService.isOnline.value ? AppColors.success : AppColors.error,
            )),
            const SizedBox(height: 16),
            Obx(() => _buildStatusRow(
              icon: Icons.pending,
              label: 'Pending Items',
              value: syncService.pendingSyncCount.value.toString(),
              color: syncService.pendingSyncCount.value > 0
                  ? AppColors.warning
                  : AppColors.success,
            )),
            const SizedBox(height: 16),
            Obx(() => _buildStatusRow(
              icon: Icons.sync,
              label: 'Status',
              value: syncService.isSyncing.value ? 'Syncing...' : 'Idle',
              color: syncService.isSyncing.value
                  ? AppColors.primary
                  : AppColors.textSecondary,
            )),
            if (syncService.lastSyncTime.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildStatusRow(
                icon: Icons.access_time,
                label: 'Last Sync',
                value: _formatLastSync(syncService.lastSyncTime.value),
                color: AppColors.textSecondary,
              ),
            ],
            const SizedBox(height: 24),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncService.isOnline.value && !syncService.isSyncing.value
                    ? () {
                        syncService.forceSync();
                        Get.back();
                      }
                    : null,
                icon: const Icon(Icons.sync),
                label: Text(syncService.isSyncing.value ? 'Syncing...' : 'Sync Now'),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatLastSync(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${difference.inDays}d ago';
    } catch (e) {
      return 'Unknown';
    }
  }
}
