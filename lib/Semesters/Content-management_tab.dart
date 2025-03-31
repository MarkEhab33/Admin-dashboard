import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/semesters_provider.dart';
import '../Theme.dart';
import 'package:intl/intl.dart';

class ContentManagementTab extends StatefulWidget {
  @override
  State<ContentManagementTab> createState() => _ContentManagementTabState();
}

class _ContentManagementTabState extends State<ContentManagementTab> {
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<SemestersProvider>().fetchSemesters(),
    );
  }

  List<int> _getAvailableYears(List<dynamic> semesters) {
    final years = semesters.map((semester) => semester.year as int).toSet().toList();
    years.sort((a, b) => b.compareTo(a)); // Sort in descending order
    return years;
  }

  List<dynamic> _getFilteredSemesters(List<dynamic> semesters) {
    if (selectedYear == null) return semesters;
    return semesters.where((semester) => semester.year == selectedYear).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SemestersProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: AppTheme.bodyLarge.copyWith(color: Colors.red),
              ),
            );
          }

          final availableYears = _getAvailableYears(provider.semesters);
          final filteredSemesters = _getFilteredSemesters(provider.semesters);

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semesters Management',
                      style: AppTheme.headingLarge,
                    ),
                    Row(
                      children: [
                        // Year Filter Dropdown
                        Container(
                          padding: const EdgeInsets.only(right: 16),
                          child: Row(
                            children: [
                              Text(
                                'Filter by Year: ',
                                style: AppTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.primaryColor),
                                ),
                                child: DropdownButton<int?>(
                                  value: selectedYear,
                                  hint: Text('All Years', style: AppTheme.bodyMedium),
                                  underline: Container(),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('All Years', style: AppTheme.bodyMedium),
                                    ),
                                    ...availableYears.map((year) => DropdownMenuItem<int?>(
                                      value: year,
                                      child: Text(year.toString(), style: AppTheme.bodyMedium),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedYear = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Add new semester logic
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Semester'),
                          style: AppTheme.primaryButtonStyle,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    children: [
                      // Headers
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildHeaderCell('Semester Name', 2),
                            _buildHeaderCell('Year', 1),
                            _buildHeaderCell('Start Date', 2),
                            _buildHeaderCell('End Date', 2),
                            _buildHeaderCell('Subjects', 1),
                            _buildHeaderCell('Students', 1),
                            const SizedBox(width: 60),
                          ],
                        ),
                      ),
                      if (filteredSemesters.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No semesters found for the selected year',
                            style: AppTheme.bodyLarge,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredSemesters.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 24,
                            endIndent: 24,
                          ),
                          itemBuilder: (context, index) {
                            final semester = filteredSemesters[index];
                            return _buildSemesterRow(semester);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCell(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AppTheme.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildSemesterRow(dynamic semester) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  semester.name,
                  style: AppTheme.bodyLarge,
                ),
                if (semester.isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Current',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              semester.year.toString(),
              style: AppTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('MMM d, y').format(semester.startDate),
              style: AppTheme.bodyLarge,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('MMM d, y').format(semester.endDate),
              style: AppTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: Text(
              semester.semesterTemplate.subjects.length.toString(),
              style: AppTheme.bodyLarge,
            ),
          ),
          Expanded(
            child: Text(
              semester.students.length.toString(),
              style: AppTheme.bodyLarge,
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              onPressed: () {
                // Navigate to semester detail
              },
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.surfaceColor,
                padding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
