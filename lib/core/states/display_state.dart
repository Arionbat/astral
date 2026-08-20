import 'package:signals_flutter/signals_flutter.dart';

/// 用户列表排序维度（持久化为 int：0/1/2）
enum UserSortOption {
  none,
  latency,
  nameLength;

  static UserSortOption fromIndex(int index) {
    if (index < 0 || index >= values.length) return UserSortOption.none;
    return values[index];
  }
}

/// 排序方向（持久化为 int：0 升序 / 1 降序）
enum UserSortOrder {
  ascending,
  descending;

  static UserSortOrder fromIndex(int index) {
    if (index < 0 || index >= values.length) return UserSortOrder.ascending;
    return values[index];
  }
}

/// 节点显示过滤（持久化为 int：0 全部 / 1 仅用户 / 2 仅服务器）
enum UserDisplayMode {
  all,
  users,
  servers;

  static UserDisplayMode fromIndex(int index) {
    if (index < 0 || index >= values.length) return UserDisplayMode.all;
    return values[index];
  }
}

/// 成员列表卡片样式（持久化为 int：0 简约 / 1 详细 / 2 列表）
enum UserListStyle {
  simple,
  detailed,
  list;

  static UserListStyle fromIndex(int index) {
    if (index < 0 || index >= values.length) return UserListStyle.simple;
    return values[index];
  }
}

/// 显示相关状态（排序、显示模式等）
class DisplayState {
  final sortOption = signal(UserSortOption.none);
  final sortOrder = signal(UserSortOrder.ascending);
  final displayMode = signal(UserDisplayMode.all);
  final userListStyle = signal(UserListStyle.simple);

  /// 兼容旧调用：是否为简约卡片
  bool get userListSimple => userListStyle.value == UserListStyle.simple;

  void setSortOption(UserSortOption option) {
    sortOption.value = option;
  }

  void setSortOrder(UserSortOrder order) {
    sortOrder.value = order;
  }

  void setDisplayMode(UserDisplayMode mode) {
    displayMode.value = mode;
  }

  void setUserListStyle(UserListStyle style) {
    userListStyle.value = style;
  }

  void setUserListSimple(bool value) {
    userListStyle.value =
        value ? UserListStyle.simple : UserListStyle.detailed;
  }
}
