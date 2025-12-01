import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../Models/semester_template.dart';
import '../provider/semester_templates_provider.dart';
import '../provider/semesters_provider.dart';
import '../Theme.dart';
import '../l10n/app_localizations.dart';
import 'semester-page.dart';

class ContentManagementTab extends StatefulWidget {
  @override
  State<ContentManagementTab> createState() => _ContentManagementTabState();
}

class _ContentManagementTabState extends State<ContentManagementTab> {
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SemestersProvider>().fetchSemesters();
      context.read<SemestersTemplatesProvider>().fetchSemesters();
    });
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

  void _showAddSemesterDialog() {
    final nameController = TextEditingController();
    final yearController = TextEditingController();
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    SemesterTemplate? selectedTemplate;
    DateTime? startDate;
    DateTime? endDate;

    // Fetch templates before showing dialog
    Provider.of<SemestersTemplatesProvider>(context, listen: false).fetchSemesters();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.addNewSemester, style: AppTheme.headingMedium),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Semester Template Dropdown
                    Consumer<SemestersTemplatesProvider>(
                      builder: (context, templateProvider, child) {
                        if (templateProvider.semesters.isEmpty) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return DropdownButtonFormField<SemesterTemplate>(
                          decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.selectTemplate),
                          value: selectedTemplate,
                          hint: Text(AppLocalizations.of(context)!.selectSemesterTemplate),
                          items: templateProvider.semesters.map((template) {
                            return DropdownMenuItem(
                              value: template,
                              child: Text('${AppLocalizations.of(context)!.semesterNumber} ${template.semesterNo}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTemplate = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    TextField(
                      controller: nameController,
                      decoration: AppTheme.inputDecoration('Semester Name (e.g. Spring 2024)'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Year Field
                    TextField(
                      controller: yearController,
                      decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.academicYear),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Start Date Field
                    TextField(
                      controller: startDateController,
                      decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.startDate).copyWith(
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            startDate = date;
                            startDateController.text = DateFormat('MMM d, y').format(date);
                            // Clear end date if it's before new start date
                            if (endDate != null && endDate!.isBefore(date)) {
                              endDate = null;
                              endDateController.text = '';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // End Date Field
                    TextField(
                      controller: endDateController,
                      decoration: AppTheme.inputDecoration(AppLocalizations.of(context)!.endDate).copyWith(
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectStartDateFirst)),
                          );
                          return;
                        }

                        final date = await showDatePicker(
                          context: context,
                          initialDate: startDate!.add(Duration(days: 1)),
                          firstDate: startDate!.add(Duration(days: 1)),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme.primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            endDate = date;
                            endDateController.text = DateFormat('MMM d, y').format(date);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedTemplate == null ||
                        nameController.text.isEmpty ||
                        yearController.text.isEmpty ||
                        startDate == null ||
                        endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFillAllFields)),
                      );
                      return;
                    }

                    try {
                      await Provider.of<SemestersProvider>(context, listen: false)
                          .addSemester(
                            semesterTemplateId: selectedTemplate!.id,
                            year: int.parse(yearController.text),
                            name: nameController.text,
                            startDate: startDate!,
                            endDate: endDate!,
                          );
                      Navigator.pop(context);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.semesterCreatedSuccessfully)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
                  style: AppTheme.primaryButtonStyle,
                  child: Text(AppLocalizations.of(context)!.create),
                ),
              ],
            );
          },
        );
      },
    );
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
                      AppLocalizations.of(context)!.semestersManagement,
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
                                  hint: Text(AppLocalizations.of(context)!.allYears, style: AppTheme.bodyMedium),
                                  underline: Container(),
                                  items: [
                                    DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(AppLocalizations.of(context)!.allYears, style: AppTheme.bodyMedium),
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
                          onPressed: () => _showAddSemesterDialog(),
                          icon: const Icon(Icons.add, size: 18, color: Colors.white),
                          label: Text(AppLocalizations.of(context)!.addNewSemester),
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
                            _buildHeaderCell(AppLocalizations.of(context)!.semesterName, 2),
                            _buildHeaderCell(AppLocalizations.of(context)!.academicYear, 1),
                            _buildHeaderCell(AppLocalizations.of(context)!.startDate, 2),
                            _buildHeaderCell(AppLocalizations.of(context)!.endDate, 2),
                            _buildHeaderCell(AppLocalizations.of(context)!.subjects, 1),
                            _buildHeaderCell(AppLocalizations.of(context)!.students, 1),
                            const SizedBox(width: 60),
                          ],
                        ),
                      ),
                      if (filteredSemesters.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            AppLocalizations.of(context)!.noSemestersFoundForSelectedYear,
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
    return InkWell(  // Added InkWell for tap effect
      onTap: () {
        context.go('/semester/${semester.id}');
      },
      child: Container(
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
                        AppLocalizations.of(context)!.current,
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
                  context.go('/semester/${semester.id}');
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.surfaceColor,
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
