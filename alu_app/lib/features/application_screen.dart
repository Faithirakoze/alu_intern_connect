import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF2563EB),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Applied'),
            Tab(text: 'Review'),
            Tab(text: 'Accepted'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to view applications.'))
          : TabBarView(
              controller: _tabController,
              children: [
                _ApplicationsList(userId: userId, filter: 'pending'),
                _ApplicationsList(userId: userId, filter: 'under_review'),
                _ApplicationsList(userId: userId, filter: 'accepted'),
                _ApplicationsList(userId: userId, filter: 'all'),
              ],
            ),
    );
  }
}

// ─── Applications list ────────────────────────────────────────────────────────

class _ApplicationsList extends StatelessWidget {
  final String userId;
  final String filter;

  const _ApplicationsList({
    required this.userId,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('applications')
        .where('applicantId', isEqualTo: userId)
        .orderBy('appliedAt', descending: true);

    if (filter != 'all') {
      query = query.where('status', isEqualTo: filter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2563EB)),
          );
        }

        if (snapshot.hasError) {
          // Surface the real error instead of silently showing "no
          // applications". A common cause here is a missing Firestore
          // composite index for the applicantId + status + appliedAt
          // (or applicantId + appliedAt) query combo — check the debug
          // console, the error message usually includes a direct link
          // to create the required index.
          debugPrint('Applications query error: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 48, color: Color(0xFFEF4444)),
                  const SizedBox(height: 12),
                  const Text(
                    'Couldn\'t load applications',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.work_off_outlined,
                    size: 56, color: Color(0xFF94A3B8)),
                const SizedBox(height: 12),
                Text(
                  filter == 'all'
                      ? 'No applications yet.'
                      : 'No applications here.',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 15),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start applying to opportunities!',
                  style: TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return _ApplicationCard(data: data);
          },
        );
      },
    );
  }
}

// ─── Application card ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ApplicationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final appliedAt = data['appliedAt'] != null
        ? (data['appliedAt'] as Timestamp).toDate()
        : DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline_rounded,
                color: Color(0xFF2563EB), size: 22),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data['opportunityTitle'] ?? 'Opportunity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const Icon(Icons.bookmark_border_rounded,
                        color: Color(0xFF94A3B8), size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data['startupName'] ?? '',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied ${_timeAgo(appliedAt)}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    _StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 6) return '${(diff.inDays / 7).floor()} week(s) ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    return 'today';
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'under_review' => ('Under Review', const Color(0xFFF59E0B)),
      'shortlisted'  => ('Shortlisted',  const Color(0xFF22C55E)),
      'accepted'     => ('Accepted',     const Color(0xFF2563EB)),
      'rejected'     => ('Rejected',     const Color(0xFFEF4444)),
      _              => ('Pending',      const Color(0xFF94A3B8)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}