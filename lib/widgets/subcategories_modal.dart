import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/subcategory_provider.dart';
import '../Models/Subject_Template.dart';
import '../Theme.dart';

class SubcategoriesModal extends StatefulWidget {
  final Subject subject;

  const SubcategoriesModal({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  State<SubcategoriesModal> createState() => _SubcategoriesModalState();
}

class _SubcategoriesModalState extends State<SubcategoriesModal> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch subcategories when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubcategoryProvider>(context, listen: false)
          .fetchSubcategories(widget.subject.subjectId!);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildAddSubcategorySection(),
            const SizedBox(height: 24),
            Expanded(child: _buildSubcategoriesList()),
            const SizedBox(height: 16),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.category_outlined,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subcategories',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                'Manage subcategories for ${widget.subject.subjectName}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSubcategorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Subcategory',
            style: AppTheme.headingMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: AppTheme.inputDecoration('Subcategory name').copyWith(
                    hintText: 'Enter subcategory name',
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Consumer<SubcategoryProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _addSubcategory,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.add, size: 18),
                    label: Text(provider.isLoading ? 'Adding...' : 'Add'),
                    style: AppTheme.primaryButtonStyle,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesList() {
    return Consumer<SubcategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.subcategories.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading subcategories',
                  style: AppTheme.headingMedium.copyWith(
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.red.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchSubcategories(widget.subject.subjectId!),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.subcategories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No subcategories yet',
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your first subcategory to organize content',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Existing Subcategories (${provider.subcategories.length})',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.subcategories.length,
                itemBuilder: (context, index) {
                  final subcategory = provider.subcategories[index];
                  return _buildSubcategoryCard(subcategory, provider);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubcategoryCard(SubCategory subcategory, SubcategoryProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.label,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          subcategory.name ?? 'Unnamed',
          style: AppTheme.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'ID: ${subcategory.id}',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        trailing: IconButton(
          onPressed: provider.isLoading ? null : () => _deleteSubcategory(subcategory),
          icon: Icon(
            Icons.delete_outline,
            color: provider.isLoading ? Colors.grey : Colors.red.shade600,
          ),
          tooltip: 'Delete subcategory',
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Close',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _addSubcategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a subcategory name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final provider = Provider.of<SubcategoryProvider>(context, listen: false);
    final success = await provider.addSubcategory(
      widget.subject.subjectId!,
      _nameController.text.trim(),
    );

    if (success) {
      _nameController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subcategory added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add subcategory: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSubcategory(SubCategory subcategory) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete "${subcategory.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider = Provider.of<SubcategoryProvider>(context, listen: false);
      final success = await provider.deleteSubcategory(
        widget.subject.subjectId!,
        subcategory.id!,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subcategory deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete subcategory: ${provider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
