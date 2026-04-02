import 'package:flutter/material.dart';
import '../models/agent_model.dart';
import '../services/explore_service.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _exploreService = ExploreService();
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'newest';
  String _searchQuery = '';

  final _categories = ['All', 'Research', 'Code', 'Data', 'Writing', 'Other'];
  final _sortOptions = {'newest': 'Newest', 'rating': 'Top rated', 'popular': 'Popular'};

  List<AgentModel> _filterBySearch(List<AgentModel> agents) {
    if (_searchQuery.isEmpty) return agents;
    return agents.where((a) =>
      a.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      a.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore agents',
          style: TextStyle(color: AppColors.textPrimary,
            fontSize: 16, fontWeight: FontWeight.w500)),
        actions: [
          PopupMenuButton<String>(
            color: AppColors.bgCard,
            icon: const Icon(Icons.sort_rounded, color: AppColors.textSecondary, size: 20),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => _sortOptions.entries.map((e) =>
              PopupMenuItem(value: e.key,
                child: Text(e.value,
                  style: TextStyle(
                    color: _sortBy == e.key ? AppColors.accent : AppColors.textSecondary,
                    fontSize: 13)))).toList(),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgCardBorder, width: .5),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'Search agents...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                  color: AppColors.textMuted, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final isActive = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.accentDark : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.bgCardBorder,
                      width: .5),
                  ),
                  child: Center(child: Text(cat,
                    style: TextStyle(
                      color: isActive ? AppColors.accentLight : AppColors.textMuted,
                      fontSize: 12, fontWeight: FontWeight.w500))),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<List<AgentModel>>(
            stream: _exploreService.getAgents(
              category: _selectedCategory,
              sortBy: _sortBy,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent));
              }
              final agents = _filterBySearch(snapshot.data ?? []);
              if (agents.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded,
                      color: AppColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    const Text('No agents found',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Try a different category or search',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ));
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .85,
                ),
                itemCount: agents.length,
                itemBuilder: (_, i) => _AgentCard(agent: agents[i]),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final AgentModel agent;
  const _AgentCard({required this.agent});

  static const _categoryColors = {
    'Research': AppColors.accentDark,
    'Code': Color(0xFF0F2D1A),
    'Data': Color(0xFF1A1A0A),
    'Writing': Color(0xFF1A0A1A),
    'Other': AppColors.bgCard,
  };

  static const _categoryIcons = {
    'Research': Icons.manage_search_rounded,
    'Code': Icons.code_rounded,
    'Data': Icons.bar_chart_rounded,
    'Writing': Icons.edit_note_rounded,
    'Other': Icons.auto_awesome_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = _categoryColors[agent.category] ?? AppColors.bgCard;
    final icon = _categoryIcons[agent.category] ?? Icons.auto_awesome_rounded;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgCardBorder, width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accent, size: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accentDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.primary, width: .5),
                ),
                child: Text('\$${agent.pricePerRun.toStringAsFixed(2)}/run',
                  style: const TextStyle(color: AppColors.accentLight,
                    fontSize: 9, fontWeight: FontWeight.w500))),
            ]),
            const SizedBox(height: 10),
            Text(agent.title,
              style: const TextStyle(color: AppColors.textPrimary,
                fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(child: Text(agent.description,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11,
                height: 1.4),
              maxLines: 3, overflow: TextOverflow.ellipsis)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFAC775), size: 12),
              const SizedBox(width: 3),
              Text(agent.rating.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(width: 6),
              Text('${agent.totalRuns} runs',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              const Spacer(),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.accentLight, size: 14)),
            ]),
          ],
        ),
      ),
    );
  }
}
