import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/Subject_Template.dart';
import '../provider/subcategory_provider.dart';
import '../Theme.dart';

class SubcategorySelector extends StatefulWidget {
  final int subjectId;
  final SubCategory? selectedSubcategory;
  final Function(SubCategory?) onSubcategoryChanged;

  const SubcategorySelector({
    Key? key,
    required this.subjectId,
    this.selectedSubcategory,
    required this.onSubcategoryChanged,
  }) : super(key: key);

  @override
  State<SubcategorySelector> createState() => _SubcategorySelectorState();
}

class _SubcategorySelectorState extends State<SubcategorySelector> {
  @override
  void initState() {
    super.initState();
    // Fetch subcategories when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubcategoryProvider>(context, listen: false)
          .fetchSubcategories(widget.subjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubcategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Loading subcategories...',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.error.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.red.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error loading subcategories',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.red.shade500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.fetchSubcategories(widget.subjectId),
                  icon: Icon(Icons.refresh, size: 16, color: Colors.red.shade600),
                  label: Text(
                    'Retry',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.subcategories.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      color: AppTheme.textSecondaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No subcategories available',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'This quiz will not be assigned to any subcategory',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        // Create dropdown items
        List<DropdownMenuItem<SubCategory?>> items = [
          DropdownMenuItem<SubCategory?>(
            value: null,
            child: Text(
              'No subcategory (Optional)',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ];

        items.addAll(
          provider.subcategories.map((subcategory) {
            return DropdownMenuItem<SubCategory?>(
              value: subcategory,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.label,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subcategory.name ?? 'Unnamed',
                      style: AppTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subcategory (Optional)',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<SubCategory?>(
              value: widget.selectedSubcategory,
              decoration: AppTheme.inputDecoration('Select subcategory').copyWith(
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: AppTheme.primaryColor,
                ),
                helperText: 'Choose a subcategory to organize this quiz',
                helperStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
              items: items,
              onChanged: widget.onSubcategoryChanged,
              isExpanded: true,
              hint: Text(
                'Select a subcategory (optional)',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
            if (widget.selectedSubcategory != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: ${widget.selectedSubcategory!.name}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
