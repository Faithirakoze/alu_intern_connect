import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF2563EB)),
                  );
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final fullName = data?['fullName'] ?? 'ALU Student';
                final email = data?['email'] ?? user.email ?? '';
                final role = data?['role'] ?? 'student';
                final bio = data?['bio'] ?? '';
                final skills =
                    List<String>.from(data?['skills'] ?? []);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          role == 'startup' ? 'Startup' : 'Student',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Stats row ──────────────────────────────
                      _StatsRow(userId: user.uid),

                      const SizedBox(height: 24),

                      // ── Bio ────────────────────────────────────
                      if (bio.isNotEmpty) ...[
                        _SectionCard(
                          title: 'About me',
                          child: Text(
                            bio,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Skills ─────────────────────────────────
                      if (skills.isNotEmpty) ...[
                        _SectionCard(
                          title: 'Skills',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map((s) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(s,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF2563EB),
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // ── Menu items ─────────────────────────────
                      _MenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'My Profile',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.lightbulb_outline_rounded,
                            label: 'Skills & Interests',
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.bookmark_border_rounded,
                            label: 'Saved Opportunities',
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () {},
                          ),
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _MenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.logout_rounded,
                            label: 'Logout',
                            color: const Color(0xFFEF4444),
                            onTap: () async {
                              await ref
                                  .read(authServiceProvider)
                                  .logout();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
    );
  }
}


class _StatsRow extends StatelessWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('applications')
          .where('applicantId', isEqualTo: userId)
          .get(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final total = docs.length;
        final shortlisted =
            docs.where((d) => (d.data() as Map)['status'] == 'shortlisted').length;
        final accepted =
            docs.where((d) => (d.data() as Map)['status'] == 'accepted').length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(value: '$total', label: 'Applications'),
              _Divider(),
              _StatItem(value: '$shortlisted', label: 'Shortlisted'),
              _Divider(),
              _StatItem(value: '$accepted', label: 'Accepted'),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            )),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              )),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}


class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (i < items.length - 1)
                const Divider(
                    height: 1, indent: 56, color: Color(0xFFE2E8F0)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF0F172A);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color != null
              ? color!.withOpacity(0.1)
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 18),
      ),
      title: Text(label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: c,
          )),
      trailing: color == null
          ? const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Color(0xFF94A3B8))
          : null,
    );
  }
}