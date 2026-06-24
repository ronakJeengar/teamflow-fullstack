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
      final response = await apiService.getList<NotificationModel>(
        ApiEndpoints.notifications,
        fromJson: (json) => NotificationModel.fromJson(json),
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
