import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/async_value.dart';
import '../services/repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/async_view.dart';
import '../widgets/cards.dart';
import '../widgets/common.dart';
import 'create_group_sheet.dart';
import 'group_details_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  AsyncValue<List<Group>> _state = const AsyncLoading();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const AsyncLoading());
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final groups = await Repository.instance.groups();
      if (!mounted) return;
      setState(() => _state = AsyncData(groups));
    } catch (e) {
      if (!mounted) return;
      setState(() => _state = AsyncError(e.toString()));
    }
  }

  Future<void> _createGroup() async {
    final created = await CreateGroupSheet.show(context);
    if (created) await _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'create_group_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        onPressed: _createGroup,
        icon: const Icon(Icons.add_rounded),
        label: Text('Create Group', style: AppType.bodyLarge),
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: _fetch,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.x20, AppSpacing.x16, AppSpacing.x20, 120),
            children: [
              Text('Groups', style: AppType.h1),
              const SizedBox(height: AppSpacing.x16),
              TextField(
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Search groups',
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppSpacing.x20),
              AsyncView<List<Group>>(
                state: _state,
                onRetry: _load,
                minLoadingHeight: 300,
                loadingLabel: 'Loading groups…',
                builder: (context, groups) {
                  final filtered = groups
                      .where((g) => g.name.toLowerCase().contains(_query))
                      .toList();
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.groups_rounded,
                      title: _query.isEmpty ? 'No groups yet' : 'No matches',
                      cta: 'Create your first group',
                      onCta: _createGroup,
                    );
                  }
                  return Column(
                    children: [
                      for (final g in filtered)
                        GroupCard(
                          group: g,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => GroupDetailsScreen(group: g)),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
