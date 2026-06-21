import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/reusable_widgets.dart';
import '../../../../core/ui/shared_widgets.dart'; // contains AppRoleBadge
import '../../domain/entities/invitation_entity.dart';

class InvitationCard extends StatelessWidget {
  final InvitationEntity invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const InvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  });

  String get _expiresLabel {
    try {
      final d = DateTime.parse(invitation.expiresAt.toIso8601String());
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return 'Expires ${months[d.month - 1]} ${d.day}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg), // 16px
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Row(
              children: [
                Avatar(name: invitation.team.name, size: 40),
                SizedBox(width: AppSpacing.md), // 12px
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.team.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Invited as ${invitation.role}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppRoleBadge(role: invitation.role),
              ],
            ),

            SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.border, height: 1),
            SizedBox(height: AppSpacing.md),

            // ── Footer ──────────────────────────────────
            Row(
              children: [
                if (_expiresLabel.isNotEmpty) ...[
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: AppColors.muted,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _expiresLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.muted,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),

                // Decline
                OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Text('Decline'),
                ),

                SizedBox(width: AppSpacing.sm), // 8px

                // Accept
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
