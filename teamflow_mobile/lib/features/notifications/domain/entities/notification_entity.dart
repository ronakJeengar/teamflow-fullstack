import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

@freezed
abstract class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String userId,
    required String senderId,
    required String type,
    required String title,
    required String body,
    required bool isRead,
    required String createdAt,
  }) = _NotificationEntity;
}
