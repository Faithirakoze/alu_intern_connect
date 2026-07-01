import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/opportunity_provider.dart';
import '../models/opportunity.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'there';
    final opportunities = ref.watch(opportunitiesProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── 1. HEADER ─────────────────────────────────────────
            _Header(firstName: firstName, ref: ref),

            const SizedBox(height: 20),

            // ── 2. SEARCH BAR ─────────────────────────────────────
            const _SearchBar(),

            const SizedBox(height: 28),

            // ── 3. RECOMMENDED ────────────────────────────────────
            const _SectionHeader(title: 'Recommended', showSeeAll: true),
            const SizedBox(height: 12),

            // Show first opportunity as the featured card
            opportunities.when(
              loading: () => const _RecommendedCardSkeleton(),
              error: (e, _) => const _RecommendedCardSkeleton(),
              data: (list) {
                if (list.isEmpty) return const _EmptyCard();
                return _RecommendedCard(opportunity: list.first);
              },
            ),

            const SizedBox(height: 28),

            // ── 4. CATEGORIES ─────────────────────────────────────
            const _SectionHeader(title: 'Browse by category'),
            const SizedBox(height: 12),
            const _CategoryRow(),

            const SizedBox(height: 28),

            // ── 5. RECENT OPPORTUNITIES ───────────────────────────
            const _SectionHeader(title: 'Recent opportunities'),
            const SizedBox(height: 12),

            opportunities.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
              error: (e, _) => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Could not load opportunities.')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No opportunities yet.')),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  itemBuilder: (_, i) =>
                      _RecentOpportunityTile(opportunity: list[i]),
                );
              },
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String firstName;
  final WidgetRef ref;
  const _Header({required this.firstName, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Find meaningful ways to contribute.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_outlined,
              color: Color(0xFF2563EB), size: 22),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            await ref.read(authServiceProvider).logout();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded,
              color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Search opportunities...',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.tune_rounded,
                color: Color(0xFF2563EB), size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showSeeAll;
  const _SectionHeader({required this.title, this.showSeeAll = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            )),
        if (showSeeAll)
          const Text('See all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              )),
      ],
    );
  }
}

// ─── Recommended card (real data) ─────────────────────────────────────────────

class _RecommendedCard extends StatelessWidget {
  final Opportunity opportunity;
  const _RecommendedCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bookmark_border_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            opportunity.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.business_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(opportunity.startupName,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: opportunity.skills
                .take(3)
                .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(s,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(opportunity.commitmentType,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Text(
                _timeAgo(opportunity.postedAt),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'Posted ${diff.inDays}d ago';
    if (diff.inHours > 0) return 'Posted ${diff.inHours}h ago';
    return 'Just posted';
  }
}

// ─── Skeleton loader for recommended card ─────────────────────────────────────

class _RecommendedCardSkeleton extends StatelessWidget {
  const _RecommendedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Column(
        children: [
          Icon(Icons.work_off_outlined,
              size: 40, color: Color(0xFF93C5FD)),
          SizedBox(height: 8),
          Text('No opportunities posted yet.',
              style: TextStyle(color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

// ─── Category row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const _categories = [
    (icon: Icons.palette_outlined, label: 'Design'),
    (icon: Icons.code_rounded, label: 'Engineering'),
    (icon: Icons.campaign_outlined, label: 'Marketing'),
    (icon: Icons.bar_chart_rounded, label: 'Data'),
    (icon: Icons.apps_rounded, label: 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _categories
          .map((cat) => Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(cat.icon,
                        color: const Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(cat.label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ))
          .toList(),
    );
  }
}

// ─── Recent opportunity tile (real data) ──────────────────────────────────────

class _RecentOpportunityTile extends StatelessWidget {
  final Opportunity opportunity;
  const _RecentOpportunityTile({required this.opportunity});

  // Pick icon color based on category
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
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
                Text(opportunity.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    )),
                const SizedBox(height: 3),
                Text(
                  '${opportunity.startupName}  •  ${opportunity.commitmentType}  •  ${opportunity.locationType}',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.bookmark_border_rounded,
              color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }
}