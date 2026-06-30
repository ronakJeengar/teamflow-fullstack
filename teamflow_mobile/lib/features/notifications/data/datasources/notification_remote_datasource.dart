import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiService.get<List<NotificationModel>>(
        ApiEndpoints.notifications,
        fromJson: (json) {
          final List<dynamic> list = [];
          if (json is Map<String, dynamic>) {
            if (json['today'] is List) list.addAll(json['today']);
            if (json['yesterday'] is List) list.addAll(json['yesterday']);
            if (json['older'] is List) list.addAll(json['older']);
          } else if (json is List) {
            list.addAll(json);
          }
          
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => NotificationModel.fromJson(e))
              .toList();
        },
      );
      if (response.status && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      throw ServerException('Failed to fetch notifications');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      final response = await apiService.patch(
        ApiEndpoints.markNotificationAsRead(id),
        fromJson: (_) => {},
      );
      if (!response.status) {
        throw ServerException(response.message);
      }
    } catch (e) {
      throw ServerException('Failed to mark notification as read');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await apiService.patch(
        ApiEndpoints.readAllNotifications,
        fromJson: (_) => {},
      );
      if (!response.status) {
        throw ServerException(response.message);
      }
    } catch (e) {
      throw ServerException('Failed to mark all notifications as read');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiService.get(
        ApiEndpoints.unreadNotificationsCount,
        fromJson: (json) => json['count'] as int,
      );
      if (response.status && response.data != null) {
        return response.data!;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
