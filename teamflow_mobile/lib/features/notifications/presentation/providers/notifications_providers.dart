import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return sl<NotificationRepository>();
});

final unreadNotificationsCountProvider = StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.watch(notificationRepositoryProvider));
});

class UnreadCountNotifier extends StateNotifier<int> {
  final NotificationRepository repository;

  UnreadCountNotifier(this.repository) : super(0) {
    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => null,
      (count) => state = count,
    );
  }

  void decrement() {
    if (state > 0) state--;
  }

  void reset() {
    state = 0;
  }
}

// Notifications List

final notificationsListProvider = StateNotifierProvider<NotificationsListNotifier, AsyncValue<List<NotificationEntity>>>((ref) {
  return NotificationsListNotifier(
    ref.watch(notificationRepositoryProvider),
    ref.read(unreadNotificationsCountProvider.notifier),
  );
});

class NotificationsListNotifier extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final NotificationRepository repository;
  final UnreadCountNotifier unreadCountNotifier;

  NotificationsListNotifier(this.repository, this.unreadCountNotifier) : super(const AsyncLoading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncLoading();
    final result = await repository.getNotifications();
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (list) {
        state = AsyncData(list);
        unreadCountNotifier.loadUnreadCount();
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await repository.markAsRead(id);
    result.fold(
      (failure) => null,
      (_) {
        state.whenData((list) {
          final updated = list.map((n) {
            if (n.id == id && !n.isRead) {
              unreadCountNotifier.decrement();
              return NotificationEntity(
                id: n.id,
                userId: n.userId,
                senderId: n.senderId,
                type: n.type,
                title: n.title,
                body: n.body,
                isRead: true,
                createdAt: n.createdAt,
              );
            }
            return n;
          }).toList();
          state = AsyncData(updated);
        });
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    result.fold(
      (failure) => null,
      (_) {
        state.whenData((list) {
          final updated = list.map((n) {
            return NotificationEntity(
              id: n.id,
              userId: n.userId,
              senderId: n.senderId,
              type: n.type,
              title: n.title,
              body: n.body,
              isRead: true,
              createdAt: n.createdAt,
            );
          }).toList();
          state = AsyncData(updated);
          unreadCountNotifier.reset();
        });
      },
    );
  }
}
