import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/diagnostics_service.dart';
import '../../../../core/di/injection.dart';

class DiagnosticsView extends HookConsumerWidget {
  const DiagnosticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backendHealth = useState<Map<String, dynamic>?>(null);
    final isPinging = useState(false);
    final apiService = sl<ApiService>();

    Future<void> pingBackend() async {
      isPinging.value = true;
      try {
        final res = await apiService.get(
          'health',
          fromJson: (json) => json as Map<String, dynamic>,
        );
        if (res.status && res.data != null) {
          backendHealth.value = res.data;
        } else {
          backendHealth.value = {'status': 'DOWN', 'error': res.message};
        }
      } catch (e) {
        backendHealth.value = {'status': 'DOWN', 'error': e.toString()};
      } finally {
        isPinging.value = false;
      }
    }

    useEffect(() {
      pingBackend();
      return null;
    }, []);

    final startupMs = DiagnosticsService.startupDuration?.inMilliseconds ?? 0;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'System Diagnostics & Health Monitor',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),

          // Startup timing card
          _buildMetricCard(
            title: 'Cold Start Latency',
            value: startupMs > 0 ? '${startupMs}ms' : 'Calculating...',
            icon: Icons.timer_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),

          // Offline queue card
          ValueListenableBuilder<SyncStatus>(
            valueListenable: apiService.syncStatusNotifier,
            builder: (context, status, _) {
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: apiService.getQueuedMutations(),
                builder: (context, snapshot) {
                  final queueCount = snapshot.data?.length ?? 0;
                  return _buildMetricCard(
                    title: 'Offline Sync Queue',
                    value: '$queueCount pending changes (${status.name.toUpperCase()})',
                    icon: Icons.cloud_sync_outlined,
                    color: status == SyncStatus.synced
                        ? AppColors.success
                        : status == SyncStatus.pending
                            ? AppColors.warning
                            : AppColors.danger,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Backend API Health Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Backend API Health',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    if (isPinging.value)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 16, color: AppColors.muted),
                        onPressed: pingBackend,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (backendHealth.value == null)
                  Text(
                    'Pinging backend server...',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
                  )
                else ...[
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: backendHealth.value!['status'] == 'UP' ? AppColors.success : AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Server Status: ${backendHealth.value!['status']}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: backendHealth.value!['status'] == 'UP' ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (backendHealth.value!['uptime'] != null)
                    Text(
                      'Server Uptime: ${backendHealth.value!['uptime']}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  if (backendHealth.value!['error'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Error: ${backendHealth.value!['error']}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.danger),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
