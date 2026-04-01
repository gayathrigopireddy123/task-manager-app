import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Task> _tasks = [];
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  TaskStatus? get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;

  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterStatus == null || task.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  bool isTaskBlocked(Task task) {
    if (task.blockedById == null) return false;
    try {
      final blocker =
          _tasks.firstWhere((t) => t.id == task.blockedById);
      return blocker.status != TaskStatus.done;
    } catch (e) {
      return false;
    }
  }

  String? getBlockerTitle(Task task) {
    if (task.blockedById == null) return null;
    try {
      return _tasks.firstWhere((t) => t.id == task.blockedById).title;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadTasks() async {
    _tasks = await _db.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    await _db.insertTask(task);
    _tasks.add(task);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    await _db.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) _tasks[index] = task;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _db.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }
}