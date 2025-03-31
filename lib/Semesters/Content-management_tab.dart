import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/semesters_provider.dart';
import 'package:intl/intl.dart';

class ContentManagementTab extends StatefulWidget {
  @override
  State<ContentManagementTab> createState() => _ContentManagementTabState();
}

class _ContentManagementTabState extends State<ContentManagementTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<SemestersProvider>().fetchSemesters(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semester Management'),
        elevation: 0,
      ),
      body: Consumer<SemestersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Semesters',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: provider.semesters.length,
                    itemBuilder: (context, index) {
                      final semester = provider.semesters[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: semester.isCurrent ? Colors.green : Colors.grey,
                            width: semester.isCurrent ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Navigate to semester detail
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      semester.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (semester.isCurrent)
                                      const Chip(
                                        label: Text('Current'),
                                        backgroundColor: Colors.green,
                                        labelStyle: TextStyle(color: Colors.white),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                _buildInfoRow(
                                  'Start Date:',
                                  DateFormat('MMM d, y').format(semester.startDate),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'End Date:',
                                  DateFormat('MMM d, y').format(semester.endDate),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Subjects:',
                                  semester.semesterTemplate.subjects.length.toString(),
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  'Students:',
                                  semester.students.length.toString(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new semester logic
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
