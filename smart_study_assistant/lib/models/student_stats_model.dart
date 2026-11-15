class CoursePerformance {
  final String courseName;
  final String courseCode;
  final int totalQuestionsSolved;
  final int correctAnswers;
  final double averageScore;
  final String status;

  CoursePerformance({
    required this.courseName,
    required this.courseCode,
    required this.totalQuestionsSolved,
    required this.correctAnswers,
    required this.averageScore,
    required this.status,
  });
}

class StudentStats {
  final int streakDays;
  final int totalQuestionsSolved;
  final int totalNotesSummarized;
  final int totalStudyHours;
  final double overallAccuracy;
  final List<CoursePerformance> coursePerformances;
  final List<String> strongTopics;
  final List<String> weakTopics;

  StudentStats({
    required this.streakDays,
    required this.totalQuestionsSolved,
    required this.totalNotesSummarized,
    required this.totalStudyHours,
    required this.overallAccuracy,
    required this.coursePerformances,
    required this.strongTopics,
    required this.weakTopics,
  });
}
