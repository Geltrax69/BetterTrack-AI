import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/cards.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_group_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create Group — coming soon')),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text('Create Group', style: AppType.bodyLarge),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
          children: [
            Text('Groups', style: AppType.h1),
            const SizedBox(height: AppSpacing.x16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search groups',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppSpacing.x20),
            for (final g in MockData.groups)
              GroupCard(
                group: g,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => GroupDetailsScreen(group: g)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
