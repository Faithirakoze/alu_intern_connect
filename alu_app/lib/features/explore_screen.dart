import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';
import '../features/opportunity_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';

  final _categories = [
    'All', 'Design', 'Engineering', 'Marketing', 'Data', 'Other'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Explore',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Search bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF94A3B8), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Search opportunities...',
                          hintStyle:
                              TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          border: InputBorder.none,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v.trim().toLowerCase()),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color(0xFF94A3B8), size: 18),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Category filter chips ─────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Results ───────────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('opportunities')
                    .where('isOpen', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF2563EB)),
                    );
                  }

                  var results = snapshot.data!.docs
                      .map((doc) => Opportunity.fromFirestore(doc))
                      .toList();

                  // Filter by category
                  if (_selectedCategory != 'All') {
                    results = results
                        .where((o) => o.category == _selectedCategory)
                        .toList();
                  }

                  // Filter by search query
                  if (_query.isNotEmpty) {
                    results = results
                        .where((o) =>
                            o.title.toLowerCase().contains(_query) ||
                            o.startupName.toLowerCase().contains(_query))
                        .toList();
                  }

                  if (results.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 56, color: Color(0xFF94A3B8)),
                          const SizedBox(height: 12),
                          Text(
                            _query.isNotEmpty
                                ? 'No results for "$_query"'
                                : 'No opportunities in this category',
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        _OpportunityCard(opportunity: results[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Opportunity card ─────────────────────────────────────────────────────────

class _OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  Color _categoryColor(String category) {
    switch (category) {
      case 'Engineering':
        return const Color(0xFF3B82F6);
      case 'Design':
        return const Color(0xFF8B5CF6);
      case 'Marketing':
        return const Color(0xFF10B981);
      case 'Data':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Engineering':
        return Icons.code_rounded;
      case 'Design':
        return Icons.palette_outlined;
      case 'Marketing':
        return Icons.campaign_outlined;
      case 'Data':
        return Icons.bar_chart_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(opportunity.category);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OpportunityDetailScreen(opportunity: opportunity),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(opportunity.category),
                      color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opportunity.startupName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.bookmark_border_rounded,
                    color: Color(0xFF94A3B8), size: 20),
              ],
            ),

            const SizedBox(height: 12),

            // Skills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: opportunity.skills
                  .take(3)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.w500,
                            )),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Bottom row
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 4),
                Text(opportunity.commitmentType,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    color: Color(0xFF94A3B8), size: 14),
                const SizedBox(width: 4),
                Text(opportunity.locationType,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}