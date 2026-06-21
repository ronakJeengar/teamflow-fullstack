import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/ui/app_tokens.dart';
import '../../../../core/ui/shared_widgets.dart';
import '../providers/invitations_providers.dart';

class InvitationsPage extends HookConsumerWidget {
  const InvitationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(
        () => ref
            .read(invitationsStateNotifierProvider.notifier)
            .loadInvitations(),
      );
      return null;
    }, const []);

    final state = ref.watch(invitationsStateNotifierProvider);
    final pendingAction = useState<String?>(null);

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
          pendingAction.value = null;
          HapticFeedback.successNotification();
          showAppSnackBar(
            context,
            'Welcome to the team! 🎉',
            backgroundColor: AppTokens.success,
          );
          Navigator.of(context).pop();
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

    return Scaffold(
      backgroundColor: AppTokens.bg,
      body: Column(
        children: [
          _Header(
            top: top,
            count: invitations.length,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: isLoading
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
                  ),
          ),
        ],
      ),
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
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTokens.brand,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.s20,
          AppTokens.s16,
          AppTokens.s20,
          80,
        ),
        itemCount: invitations.length,
        itemBuilder: (_, i) {
          final inv = invitations[i];
          final isBusy = pendingToken == inv.token;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.s12),
            child: _InvitationTile(
              invitation: inv,
              isBusy: isBusy,
              onAccept: isBusy ? null : () => onAccept(inv),
              onDecline: isBusy ? null : () => onDecline(inv),
            ),
          );
        },
      ),
    );
  }
}

class _InvitationTile extends StatelessWidget {
  final dynamic invitation;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const _InvitationTile({
    required this.invitation,
    required this.isBusy,
    this.onAccept,
    this.onDecline,
  });

  String get _teamName => invitation.teamName as String? ?? 'Unknown Team';

  String get _inviterName => invitation.inviterName as String? ?? '';

  String get _role => invitation.role as String? ?? 'Member';

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isBusy ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTokens.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppAvatar(name: _teamName, size: 44),

                        SizedBox(width: AppTokens.s12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _teamName,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_inviterName.isNotEmpty) ...[
                                SizedBox(height: AppTokens.s4),
                                Text(
                                  'Invited by $_inviterName',
                                  style: AppTokens.bodySm.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(width: AppTokens.s8),

                        // ← Uses shared AppRoleBadge (owner/admin/member)
                        _RoleBadge(role: _role),
                      ],
                    ),

                    SizedBox(height: AppTokens.s16),
                    Container(height: 1, color: AppTokens.border),
                    SizedBox(height: AppTokens.s14),
                    Row(
                      children: [
                        Expanded(
                          child: _TileActionButton(
                            label: 'Decline',
                            icon: Icons.close_rounded,
                            color: AppTokens.danger,
                            surface: AppTokens.dangerSurface,
                            onTap: onDecline,
                            isBusy: false,
                          ),
                        ),
                        SizedBox(width: AppTokens.s10),
                        Expanded(
                          flex: 2,
                          child: _TileActionButton(
                            label: 'Accept invite',
                            icon: Icons.check_rounded,
                            color: Colors.white,
                            surface: AppTokens.success,
                            onTap: onAccept,
                            isBusy: isBusy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return AppRoleBadge(role: role);
  }
}

class _TileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color surface;
  final VoidCallback? onTap;
  final bool isBusy;

  const _TileActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.surface,
    this.onTap,
    required this.isBusy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: isBusy
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: color),
                    SizedBox(width: AppTokens.s6),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
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
          SizedBox(height: 80),
          AppEmptyState(
            icon: Icons.mark_email_read_outlined,
            iconColor: AppTokens.brand,
            iconSurface: AppTokens.brandSurface,
            title: 'All caught up',
            subtitle:
                'No pending invitations right now.\nPull down to refresh.',
          ),
        ],
      ),
    );
  }
}
