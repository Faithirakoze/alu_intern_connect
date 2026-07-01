import 'package:flutter/material.dart';
import '../models/opportunity.dart';
import 'application_form_screen.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Opportunity Details',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Startup info row ───────────────────────────────────
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.business_rounded,
                      color: Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      opportunity.startupName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: opportunity.skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
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

            const SizedBox(height: 24),

            // ── Details row ────────────────────────────────────────
            _DetailRow(
              icon: Icons.access_time_rounded,
              text: opportunity.commitmentType,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on_outlined,
              text: opportunity.locationType,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              text: 'Posted ${_timeAgo(opportunity.postedAt)}',
            ),

            const SizedBox(height: 28),

            // ── About section ──────────────────────────────────────
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              opportunity.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 28),

            // ── Skills required ────────────────────────────────────
            const Text(
              'Skills required',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: opportunity.skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF475569),
                              fontWeight: FontWeight.w500,
                            )),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              final applied = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApplicationFormScreen(
                    opportunityId: opportunity.id,
                    opportunityTitle: opportunity.title,
                    startupName: opportunity.startupName,
                  ),
                ),
              );
              
              if (applied == true && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application submitted!'),
                    backgroundColor: Color(0xFF2563EB),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Apply Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'just now';
  }
}


class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}