import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  const TaskFormScreen({Key? key, this.existingTask}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TaskStatus _selectedStatus = TaskStatus.todo;
  String? _selectedBlockedById;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _selectedDate = t.dueDate;
      _selectedStatus = t.status;
      _selectedBlockedById = t.blockedById;
    } else {
      _loadDraft();
    }
    _titleController.addListener(_saveDraft);
    _descController.addListener(_saveDraft);
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _titleController.text = prefs.getString('draft_title') ?? '';
      _descController.text = prefs.getString('draft_desc') ?? '';
    });
  }

  Future<void> _saveDraft() async {
    if (widget.existingTask != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', _titleController.text);
    await prefs.setString('draft_desc', _descController.text);
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_desc');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTask() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    setState(() => _isSaving = true);
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final task = Task(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      dueDate: _selectedDate,
      status: _selectedStatus,
      blockedById: _selectedBlockedById,
    );
    if (widget.existingTask == null) {
      await provider.addTask(task);
      await _clearDraft();
    } else {
      await provider.updateTask(task);
    }
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      );

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) =>
      Container(
        decoration: _boxDecoration(),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final otherTasks = provider.tasks
        .where((t) => t.id != widget.existingTask?.id)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.existingTask == null ? 'New Task' : 'Edit Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Title *'),
            _buildTextField(_titleController, 'Enter task title...'),
            const SizedBox(height: 16),
            _buildLabel('Description'),
            _buildTextField(
              _descController,
              'Enter description...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildLabel('Due Date'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: _boxDecoration(),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Color(0xFF6C63FF)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Status'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: _boxDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TaskStatus>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: TaskStatus.values
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label),
                          ))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _selectedStatus = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Blocked By (Optional)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: _boxDecoration(),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _selectedBlockedById,
                  isExpanded: true,
                  hint: const Text('None'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('None')),
                    ...otherTasks.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            t.title,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (val) =>
                      setState(() => _selectedBlockedById = val),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.existingTask == null
                            ? 'Create Task'
                            : 'Update Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
