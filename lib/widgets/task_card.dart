import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final isBlocked = provider.isTaskBlocked(task);
    final blockerTitle = provider.getBlockerTitle(task);

    return Opacity(
      opacity: isBlocked ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: isBlocked ? 0 : 3,
        color: isBlocked ? Colors.grey.shade200 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isBlocked
              ? BorderSide(color: Colors.grey.shade400)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: isBlocked ? null : onTap,
          leading: CircleAvatar(
            backgroundColor: isBlocked ? Colors.grey : task.status.color,
            child: Icon(
              isBlocked ? Icons.lock_outline : _getStatusIcon(task.status),
              color: Colors.white,
              size: 18,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBlocked ? Colors.grey : Colors.black87,
              decoration: task.status == TaskStatus.done
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isBlocked ? Colors.grey : Colors.black54),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 12,
                      color: isBlocked ? Colors.grey : Colors.black45),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: TextStyle(
                        fontSize: 12,
                        color: isBlocked ? Colors.grey : Colors.black45),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isBlocked
                          ? Colors.grey.shade300
                          : task.status.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      task.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isBlocked ? Colors.grey : task.status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (isBlocked && blockerTitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  '🔒 Blocked by: $blockerTitle',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.redAccent),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.autorenew;
      case TaskStatus.done:
        return Icons.check_circle_outline;
    }
  }
}