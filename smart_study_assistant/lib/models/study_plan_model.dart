class StudyTask {
  final String id;
  final String title;
  final String course;
  final String duration;
  bool isCompleted;

  StudyTask({
    required this.id,
    required this.title,
    required this.course,
    required this.duration,
    this.isCompleted = false,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? '',
      course: json['course'] as String? ?? '',
      duration: json['duration'] as String? ?? '45 dk',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course': course,
      'duration': duration,
      'is_completed': isCompleted,
    };
  }
}

class DaySchedule {
  final String dayName;
  final String focusTopic;
  final List<StudyTask> tasks;

  DaySchedule({
    required this.dayName,
    required this.focusTopic,
    required this.tasks,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
}
