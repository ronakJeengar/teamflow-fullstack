import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../../../../core/widgets/teamflow_shell.dart';
import '../../../../core/navigation/navigation_helper.dart';
import '../../../../core/navigation/app_navigation.dart';
import '../../../auth/presentation/providers/providers.dart';
import '../providers/invitations_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

class InvitationsPage extends HookConsumerWidget {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTabIdx = useState(0);

    useEffect(() {
      Future.microtask(
        () {
          ref.read(invitationsStateNotifierProvider.notifier).loadInvitations();
          ref.read(notificationsListProvider.notifier).loadNotifications();
        },
      );
      return null;
    }, const []);

    final state = ref.watch(invitationsStateNotifierProvider);
    final pendingAction = useState<String?>(null);
    final notificationsAsync = ref.watch(notificationsListProvider);

    ref.listen<AsyncValue<void>>(
      acceptInvitationControllerProvider,
      (_, next) => next.whenOrNull(
        error: (e, _) {
          pendingAction.value = null;
          showAppSnackBar(
            context,
            'Failed to accept invitation',
            backgroundColor: AppTokens.danger,
          );
        },
        data: (_) {
          final router = GoRouter.of(context);
          final routeStackBefore = router.routerDelegate.currentConfiguration.matches
              .map((m) => m.matchedLocation)
              .toList();
          final authStateBefore = ref.read(authStateNotifierProvider);
          final selectedTabBefore = 'Inbox';

          debugPrint('--- [Navigation Audit] BEFORE INVITATION ACCEPT ---');
          debugPrint('Route Stack: $routeStackBefore');
          debugPrint('Auth Status: ${authStateBefore.status}');
          debugPrint('Memberships Count: ${authStateBefore.memberships.length}');
          debugPrint('Selected Tab: $selectedTabBefore');

          pendingAction.value = null;
          HapticFeedback.successNotification();
          showAppSnackBar(
            context,
            'Welcome to the team! 🎉',
            backgroundColor: AppTokens.success,
          );

          // Determine navigation destination based on refreshed memberships
          final authState = ref.read(authStateNotifierProvider);
          final memberships = authState.memberships;

          if (memberships.isEmpty) {
            nav.goToTeams();
          } else if (memberships.length == 1) {
            final membership = memberships.first;
            if (!['OWNER', 'ADMIN'].contains(membership.role)) {
              nav.goToTeamDetails(membership.team.id);
            } else {
              nav.goToTeams();
            }
          } else {
            nav.goToTeams();
          }

          // Log after navigation has occurred
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final routeStackAfter = router.routerDelegate.currentConfiguration.matches
                .map((m) => m.matchedLocation)
                .toList();
            final authStateAfter = ref.read(authStateNotifierProvider);
            final finalLoc = routeStackAfter.isNotEmpty ? routeStackAfter.last : '';
            String selectedTabAfter = 'Teams';
            if (finalLoc.startsWith('/teams/')) {
              selectedTabAfter = finalLoc == '/teams' ? 'Teams' : 'None (Bottom Bar Hidden)';
            }
            debugPrint('--- [Navigation Audit] AFTER INVITATION ACCEPT ---');
            debugPrint('Route Stack: $routeStackAfter');
            debugPrint('Auth Status: ${authStateAfter.status}');
            debugPrint('Memberships Count: ${authStateAfter.memberships.length}');
            debugPrint('Selected Tab: $selectedTabAfter');
          });
        },
      ),
    );

    ref.listen<AsyncValue<void>>(
      cancelInvitationControllerProvider,
      (_, next) => next.whenOrNull(
        error: (e, _) {
          pendingAction.value = null;
          showAppSnackBar(
            context,
            'Failed to decline invitation',
            backgroundColor: AppTokens.danger,
          );
        },
        data: (_) {
          pendingAction.value = null;
          showAppSnackBar(
            context,
            'Invitation declined',
            backgroundColor: AppTokens.textSecondary,
          );
        },
      ),
    );

    final invitations = state.invitations;
    final isLoading = state.isLoading && invitations.isEmpty;
    final hasError = state.error != null && invitations.isEmpty;

    final top = MediaQuery.of(context).padding.top;

    Future<void> refresh() =>
        ref.read(invitationsStateNotifierProvider.notifier).loadInvitations();

    Future<void> onAccept(dynamic inv) async {
      pendingAction.value = inv.token;
      await ref
          .read(acceptInvitationControllerProvider.notifier)
          .acceptInvitation(token: inv.token);
    }

    Future<void> onDecline(dynamic inv) async {
      pendingAction.value = inv.token;
      await ref
          .read(cancelInvitationControllerProvider.notifier)
          .cancelInvitation(teamId: inv.teamId, token: inv.token);
    }

    final isDesktop = MediaQuery.of(context).size.width > 800;

    Widget buildTabBar() {
      return Container(
        height: 38,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => activeTabIdx.value = 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeTabIdx.value == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Invitations',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: activeTabIdx.value == 0
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTabIdx.value == 0
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => activeTabIdx.value = 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: activeTabIdx.value == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: activeTabIdx.value == 1
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: activeTabIdx.value == 1
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildNotificationsView() {
      return notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: AppEmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications',
                subtitle: 'You are all caught up!',
              ),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      ref.read(notificationsListProvider.notifier).markAllAsRead();
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark all read'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(notificationsListProvider.notifier).loadNotifications(),
                  color: AppTokens.brand,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: notifications.length,
                    itemBuilder: (context, i) {
                      final n = notifications[i];
                      return ListTile(
                        leading: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: n.isRead ? AppColors.border : AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            n.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                            color: n.isRead ? AppColors.muted : AppColors.primary,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          n.body,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: !n.isRead
                            ? IconButton(
                                icon: const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                                onPressed: () {
                                  ref.read(notificationsListProvider.notifier).markAsRead(n.id);
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const AppLoadingView(message: 'Loading notifications…'),
        error: (err, stack) => AppErrorView(
          title: 'Failed to load notifications',
          message: err.toString(),
          onRetry: () => ref.read(notificationsListProvider.notifier).loadNotifications(),
        ),
      );
    }

    final bodyContent = Column(
      children: [
        if (isDesktop)
          _Header(
            top: top,
            count: invitations.length,
            onBack: () => Navigator.of(context).pop(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildTabBar(),
        ),
        Expanded(
          child: activeTabIdx.value == 0
              ? (isLoading
                  ? const AppLoadingView(message: 'Loading invitations…')
                  : hasError
                  ? AppErrorView(
                      title: 'Failed to load invitations',
                      message: state.error!,
                      onRetry: refresh,
                    )
                  : invitations.isEmpty
                  ? _EmptyState(onRefresh: refresh)
                  : _InvitationList(
                      invitations: invitations,
                      pendingToken: pendingAction.value,
                      onAccept: onAccept,
                      onDecline: onDecline,
                      onRefresh: refresh,
                    ))
              : buildNotificationsView(),
        ),
      ],
    );

    return TeamFlowShell(
      activeTab: 'Inbox',
      child: bodyContent,
    );
  }
}

class _Header extends StatelessWidget {
  final double top;
  final int count;
  final VoidCallback onBack;

  const _Header({required this.top, required this.count, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: top + AppTokens.s16),

          // Nav row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s20),
            child: Row(
              children: [
                AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
                const Spacer(),
                if (count > 0) _PendingBadge(count: count),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitations',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.textPrimary,
                    letterSpacing: -1.0,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: AppTokens.s4),
                Text(
                  count == 0
                      ? 'No pending invitations'
                      : '$count team${count == 1 ? '' : 's'} waiting for you',
                  style: AppTokens.bodySm,
                ),
              ],
            ),
          ),

          SizedBox(height: AppTokens.s20),
          Container(height: 1, color: AppTokens.border),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  final int count;

  const _PendingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
      child: Container(
        key: ValueKey(count),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s10,
          vertical: AppTokens.s4,
        ),
        decoration: BoxDecoration(
          color: AppTokens.warningSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTokens.warning,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppTokens.s6),
            Text(
              '$count pending',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTokens.warning,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationList extends StatelessWidget {
  final List<dynamic> invitations;
  final String? pendingToken;
  final ValueChanged<dynamic> onAccept;
  final ValueChanged<dynamic> onDecline;
  final Future<void> Function() onRefresh;

  const _InvitationList({
    required this.invitations,
    required this.pendingToken,
    required this.onAccept,
    required this.onDecline,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    final Map<String, List<dynamic>> grouped = {
      'TODAY': [],
      'YESTERDAY': [],
      'OLDER': [],
    };

    for (final inv in invitations) {
      final DateTime created;
      if (inv.createdAt is String) {
        created = DateTime.tryParse(inv.createdAt as String) ?? now;
      } else if (inv.createdAt is DateTime) {
        created = inv.createdAt as DateTime;
      } else {
        created = now;
      }
      final createdDate = DateTime(created.year, created.month, created.day);
      if (createdDate == todayDate) {
        grouped['TODAY']!.add(inv);
      } else if (createdDate == yesterdayDate) {
        grouped['YESTERDAY']!.add(inv);
      } else {
        grouped['OLDER']!.add(inv);
      }
    }

    final sections = <Widget>[];

    void addSection(String title, List<dynamic> items) {
      if (items.isEmpty) return;
      sections.add(
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
      for (final inv in items) {
        final isBusy = pendingToken == inv.token;
        sections.add(
          _InvitationTile(
            invitation: inv,
            isBusy: isBusy,
            onAccept: isBusy ? null : () => onAccept(inv),
            onDecline: isBusy ? null : () => onDecline(inv),
            pendingToken: pendingToken,
          ),
        );
      }
    }

    addSection('TODAY', grouped['TODAY']!);
    addSection('YESTERDAY', grouped['YESTERDAY']!);
    addSection('OLDER', grouped['OLDER']!);

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTokens.brand,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: sections,
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  final dynamic invitation;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final String? pendingToken;

  const _InvitationTile({
    required this.invitation,
    required this.isBusy,
    this.onAccept,
    this.onDecline,
    this.pendingToken,
  });

  String get _teamName {
    try {
      final dynamic inv = invitation;
      return inv.team?.name as String? ?? inv.teamName as String? ?? 'Unknown Team';
    } catch (_) {
      return 'Unknown Team';
    }
  }

  String get _inviterName {
    try {
      final dynamic inv = invitation;
      return inv.inviterName as String? ?? inv.invitedById as String? ?? 'A teammate';
    } catch (_) {
      return 'A teammate';
    }
  }

  String get _role {
    try {
      final dynamic inv = invitation;
      return inv.role as String? ?? 'Member';
    } catch (_) {
      return 'Member';
    }
  }

  String get _timeLabel {
    try {
      final DateTime created;
      if (invitation.createdAt is String) {
        created = DateTime.tryParse(invitation.createdAt as String) ?? DateTime.now();
      } else if (invitation.createdAt is DateTime) {
        created = invitation.createdAt as DateTime;
      } else {
        created = DateTime.now();
      }
      final diff = DateTime.now().difference(created);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else {
        return '${diff.inDays} days ago';
      }
    } catch (_) {
      return 'Recent';
    }
  }

  void _showInvitationActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTokens.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppAvatar(name: _teamName, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Invitation',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.textPrimary,
                            ),
                          ),
                          Text(
                            '$_teamName · $_role',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '$_inviterName has invited you to join $_teamName as a $_role.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy
                            ? null
                            : () {
                                Navigator.pop(context);
                                if (onDecline != null) onDecline!();
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.danger,
                          side: const BorderSide(color: AppTokens.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isBusy
                            ? null
                            : () {
                                Navigator.pop(context);
                                if (onAccept != null) onAccept!();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = invitation.status == 'PENDING';
    
    return InkWell(
      onTap: isBusy ? null : () => _showInvitationActions(context),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTokens.border, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Unread dot
            SizedBox(
              width: 12,
              child: isUnread
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTokens.brand,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            // Avatar
            Opacity(
              opacity: isUnread ? 1.0 : 0.6,
              child: AppAvatar(
                name: _inviterName,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_inviterName invited you to join $_teamName',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: AppTokens.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_teamName · $_timeLabel',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTokens.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Chevron or indicator
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppTokens.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTokens.brand,
      child: ListView(
        children: [
          const SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.mark_email_read_outlined,
            iconColor: AppTokens.brand,
            iconSurface: AppTokens.brandSurface,
            title: 'All caught up',
            subtitle: 'No pending invitations right now.\nPull down to refresh.',
          ),
        ],
      ),
    );
  }
}
