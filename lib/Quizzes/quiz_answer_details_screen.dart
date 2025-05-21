import 'package:admin_dashboard/Models/quiz.dart';
import 'package:admin_dashboard/Theme.dart';
import 'package:admin_dashboard/provider/quiz_answer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class QuizAnswerDetailsScreen extends StatefulWidget {
  final int quizAnswerId;
  final int quizId;

  const QuizAnswerDetailsScreen({
    Key? key,
    required this.quizAnswerId,
    required this.quizId,
  }) : super(key: key);

  @override
  _QuizAnswerDetailsScreenState createState() => _QuizAnswerDetailsScreenState();
}

class _QuizAnswerDetailsScreenState extends State<QuizAnswerDetailsScreen> {
  bool isLoading = true;
  String error = '';
  Map<String, dynamic>? quizAnswerDetails;
  Map<int, TextEditingController> questionGradeControllers = {};
  int totalAssignedGrade = 0;
  int totalPossibleGrade = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizAnswerDetails();
  }

  @override
  void dispose() {
    // Dispose all controllers
    questionGradeControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadQuizAnswerDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final provider = Provider.of<QuizAnswerProvider>(context, listen: false);
      final details = await provider.fetchQuizAnswerWithQuestions(
        widget.quizAnswerId,
        widget.quizId,
      );

      // Initialize controllers for each question
      if (details != null && details['questions'] != null) {
        totalPossibleGrade = 0;
        totalAssignedGrade = 0;

        for (var questionData in details['questions']) {
          final questionId = questionData['question']['id'];
          final grade = questionData['question']['grade'];
          totalPossibleGrade += grade is num ? grade.toInt() : 0;

          // If the question is graded, use the existing grade
          if (questionData['isGraded'] == true) {
            // For MCQ, if correct, assign full grade
            if (questionData['question']['type'] == 'mcq' && questionData['isCorrect'] == true) {
              totalAssignedGrade += grade is num ? grade.toInt() : 0;
              questionGradeControllers[questionId] = TextEditingController(text: grade.toString());
            } 
            // For other types, we need to get the assigned grade from somewhere
            // This depends on how your API returns the data
            else if (questionData['assignedGrade'] != null) {
              totalAssignedGrade += questionData['assignedGrade'] is num ? (questionData['assignedGrade'] as num).toInt() : 0;
              questionGradeControllers[questionId] = TextEditingController(
                text: questionData['assignedGrade'].toString(),
              );
            } else {
              // Default to 0 if no grade is assigned
              questionGradeControllers[questionId] = TextEditingController(text: '0');
            }
          } else {
            // Not graded yet, initialize with empty or 0
            questionGradeControllers[questionId] = TextEditingController(text: '');
          }
        }
      }

      setState(() {
        quizAnswerDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading quiz answer details: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _submitGrades() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Prepare the grades data
      final List<Map<String, dynamic>> questionGrades = [];
      
      for (var questionData in quizAnswerDetails!['questions']) {
        final questionId = questionData['question']['id'];
        final controller = questionGradeControllers[questionId];
        
        if (controller != null && controller.text.isNotEmpty) {
          questionGrades.add({
            'questionId': questionId,
            'grade': int.parse(controller.text),
          });
        }
      }

      // Calculate total grade
      int totalGrade = questionGrades.fold<int>(0, (sum, item) => sum + (item['grade'] as int));

      // Submit the grades
      final provider = Provider.of<QuizAnswerProvider>(context, listen: false);
      await provider.gradeQuizAnswerWithQuestions(
        widget.quizAnswerId,
        totalGrade,
        questionGrades,
      );

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grades submitted successfully')),
      );

      // Refresh the data
      _loadQuizAnswerDetails();
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error submitting grades: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting grades: $e')),
      );
    }
  }

  void _updateTotalGrade() {
    int total = 0;
    questionGradeControllers.forEach((_, controller) {
      if (controller.text.isNotEmpty) {
        total += int.tryParse(controller.text) ?? 0;
      }
    });

    setState(() {
      totalAssignedGrade = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Answer Details'),
        actions: [
          if (!isLoading && quizAnswerDetails != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Submit Grades'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _submitGrades,
              ),
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(error),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuizAnswerDetails,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : quizAnswerDetails == null
                  ? Center(child: Text('No data available'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          SizedBox(height: 24),
                          _buildGradeSummary(),
                          SizedBox(height: 24),
                          _buildQuestionsList(),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    final student = quizAnswerDetails!['student'];
    final quizName = quizAnswerDetails!['quizName'];
    final submissionDate = DateTime.parse(quizAnswerDetails!['submissionDate']);
    final formattedDate = DateFormat('MMM d, y HH:mm').format(submissionDate.toLocal());
    final timeTaken = quizAnswerDetails!['timeTaken'];
    final minutes = (timeTaken / 60).floor();
    final seconds = timeTaken % 60;
    final timeLimit = quizAnswerDetails!['timeLimit'];
    final attemptNumber = quizAnswerDetails!['attemptNumber'];
    final maxAttempts = quizAnswerDetails!['numberOfAttempts'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  radius: 24,
                  child: Text(
                    student['name'].isNotEmpty ? student['name'][0].toUpperCase() : '?',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: AppTheme.headingMedium,
                      ),
                      Text(
                        'Student Code: ${student['studentCode']}',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 32),
            Text(
              'Quiz: $quizName',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Submission Date',
                    formattedDate,
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Time Taken',
                    '$minutes min $seconds sec',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Time Limit',
                    '$timeLimit minutes',
                    Icons.hourglass_empty,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Attempt',
                    '$attemptNumber of $maxAttempts',
                    Icons.repeat,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSummary() {
    final quizGrade = quizAnswerDetails!['quizGrade'];
    final currentGrade = quizAnswerDetails!['grade'];
    final isGraded = currentGrade != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grade Summary',
              style: AppTheme.headingMedium,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Grade',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        isGraded ? '$currentGrade / $quizGrade' : 'Not Graded',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isGraded ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned Grade (Current)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '$totalAssignedGrade / $totalPossibleGrade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalPossibleGrade > 0 ? totalAssignedGrade / totalPossibleGrade : 0,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList() {
    final questions = quizAnswerDetails!['questions'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions & Answers',
          style: AppTheme.headingMedium,
        ),
        SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          separatorBuilder: (context, index) => SizedBox(height: 16),
          itemBuilder: (context, index) {
            final questionData = questions[index];
            return _buildQuestionItem(questionData, index);
          },
        ),
      ],
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> questionData, int index) {
    final question = questionData['question'];
    final answer = questionData['answer'];
    final isCorrect = questionData['isCorrect'];
    final isGraded = questionData['isGraded'];
    final questionType = question['type'];
    final questionId = question['id'];
    final questionGrade = question['grade'];
    final controller = questionGradeControllers[questionId];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question['text'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${questionType.toUpperCase()} - $questionGrade pts',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildAnswerSection(questionType, question, answer, isCorrect),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Assign Grade (max: $questionGrade)',
                      border: OutlineInputBorder(),
                      suffixText: 'points',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _updateTotalGrade();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a grade';
                      }
                      final grade = int.tryParse(value);
                      if (grade == null) {
                        return 'Please enter a valid number';
                      }
                      if (grade < 0) {
                        return 'Grade cannot be negative';
                      }
                      if (grade > questionGrade) {
                        return 'Grade cannot exceed maximum';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                if (questionType == 'mcq')
                  ElevatedButton(
                    onPressed: () {
                      // For MCQ, set full grade if correct, 0 if incorrect
                      if (isCorrect == true) {
                        controller?.text = questionGrade.toString();
                      } else {
                        controller?.text = '0';
                      }
                      _updateTotalGrade();
                    },
                    child: Text('Auto Grade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(
    String questionType,
    Map<String, dynamic> question,
    Map<String, dynamic> answer,
    bool? isCorrect,
  ) {
    switch (questionType) {
      case 'mcq':
        return _buildMCQAnswer(question, answer, isCorrect);
      case 'text':
        return _buildTextAnswer(question, answer);
      case 'record':
        return _buildRecordingAnswer(answer);
      default:
        return Text('Unknown question type');
    }
  }

  Widget _buildMCQAnswer(
    Map<String, dynamic> question,
    Map<String, dynamic> answer,
    bool? isCorrect,
  ) {
    final options = question['options'] as List;
    final selectedAnswerId = answer['selectedAnswerId'];
    final correctAnswerId = question['correctAnswerId'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...options.map((option) {
          final isSelected = option['id'] == selectedAnswerId;
          final isCorrectOption = option['id'] == correctAnswerId;
          
          Color? textColor;
          if (isSelected) {
            textColor = isCorrectOption ? Colors.green : Colors.red;
          }
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected 
                      ? (isCorrectOption ? Colors.green : Colors.red)
                      : (isCorrectOption ? Colors.green.withOpacity(0.5) : Colors.grey),
                ),
                SizedBox(width: 8),
                Text(
                  option['text'],
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected || isCorrectOption ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected && isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                  ),
                if (isSelected && !isCorrectOption)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.cancel, color: Colors.red, size: 16),
                  ),
              ],
            ),
          );
        }).toList(),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCorrect == true 
                ? Colors.green.withOpacity(0.1) 
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCorrect == true ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isCorrect == true ? Icons.check_circle : Icons.cancel,
                color: isCorrect == true ? Colors.green : Colors.red,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                isCorrect == true ? 'Correct Answer' : 'Incorrect Answer',
                style: TextStyle(
                  color: isCorrect == true ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextAnswer(Map<String, dynamic> question, Map<String, dynamic> answer) {
    final textAnswer = answer['textAnswer'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Answer:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            textAnswer ?? 'No answer provided',
            style: TextStyle(
              fontStyle: textAnswer == null ? FontStyle.italic : FontStyle.normal,
              color: textAnswer == null ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingAnswer(Map<String, dynamic> answer) {
    final recordingUrl = answer['recordingUrl'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio Recording:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        if (recordingUrl != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.audiotrack, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Audio recording available',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow),
                  label: Text('Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Implement audio playback functionality
                    // This would typically use a package like just_audio
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Audio playback not implemented in this demo')),
                    );
                  },
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'No recording provided',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

}




