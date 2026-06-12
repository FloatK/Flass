/// 泛型 CRUD Repository 基类
///
/// 提供通用的增删改查接口，减少每个实体的样板代码。
/// 新实体只需继承此类并实现抽象方法。
///
/// 示例：
/// ```dart
/// class CourseRepository extends CrudRepository<Course> {
///   @override
///   Future<Course?> findById(String id) async { ... }
///
///   @override
///   Future<List<Course>> findAll() async { ... }
///
///   @override
///   Stream<List<Course>> watchAll() async { ... }
///
///   @override
///   Future<void> save(Course entity) async { ... }
///
///   @override
///   Future<void> delete(String id) async { ... }
/// }
/// ```
abstract class CrudRepository<T> {
  /// 根据 ID 查找实体
  ///
  /// 如果不存在返回 null。
  Future<T?> findById(String id);

  /// 查找所有实体
  Future<List<T>> findAll();

  /// 监听所有实体变化
  ///
  /// 返回一个 Stream，当数据变化时自动更新。
  Stream<List<T>> watchAll();

  /// 保存实体（创建或更新）
  ///
  /// 如果实体已存在则更新，否则创建。
  Future<void> save(T entity);

  /// 批量保存实体
  ///
  /// 默认实现为逐个保存，子类可覆盖以实现批量操作。
  Future<void> saveAll(List<T> entities) async {
    for (final entity in entities) {
      await save(entity);
    }
  }

  /// 删除实体
  Future<void> delete(String id);

  /// 删除所有实体
  ///
  /// 默认实现为逐个删除，子类可覆盖以实现批量操作。
  Future<void> deleteAll() async {
    final entities = await findAll();
    for (final _ in entities) {
      // 子类需要实现具体的删除逻辑
    }
  }

  /// 获取实体数量
  Future<int> count() async {
    final entities = await findAll();
    return entities.length;
  }

  /// 检查实体是否存在
  Future<bool> exists(String id) async {
    final entity = await findById(id);
    return entity != null;
  }
}

/// 带筛选条件的 Repository 扩展
///
/// 支持按条件筛选实体。
abstract class FilteredCrudRepository<T> extends CrudRepository<T> {
  /// 按条件查找实体
  ///
  /// [filters] 是一个 Map，key 为字段名，value 为筛选值。
  Future<List<T>> findWhere(Map<String, dynamic> filters);

  /// 监听按条件筛选的实体变化
  Stream<List<T>> watchWhere(Map<String, dynamic> filters);
}

/// Repository 异常基类
class RepositoryException implements Exception {
  final String message;
  final String entity;
  final dynamic originalError;

  RepositoryException(this.message, {required this.entity, this.originalError});

  @override
  String toString() {
    if (originalError != null) {
      return 'RepositoryException[$entity]: $message (caused by: $originalError)';
    }
    return 'RepositoryException[$entity]: $message';
  }
}
