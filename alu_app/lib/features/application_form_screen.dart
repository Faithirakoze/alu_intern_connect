import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Navigate here from your Opportunity Details screen's "Apply Now" button:
///
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ApplicationFormScreen(
///       opportunityId: opportunity.id,
///       opportunityTitle: opportunity.title,
///       startupName: opportunity.startupName,
///     ),
///   ),
/// );
class ApplicationFormScreen extends StatefulWidget {
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;

  const ApplicationFormScreen({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
  });

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _phoneController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _resumeLinkController = TextEditingController();
  final _coverLetterController = TextEditingController();

  bool _isSubmitting = false;
  bool _isCheckingExisting = true;
  bool _alreadyApplied = false;

  static const _primaryBlue = Color(0xFF2563EB);
  static const _textDark = Color(0xFF0F172A);
  static const _textGrey = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _checkExistingApplication();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedInController.dispose();
    _resumeLinkController.dispose();
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingApplication() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isCheckingExisting = false);
      return;
    }

    final existing = await FirebaseFirestore.instance
        .collection('applications')
        .where('applicantId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: widget.opportunityId)
        .limit(1)
        .get();

    if (!mounted) return;
    setState(() {
      _alreadyApplied = existing.docs.isNotEmpty;
      _isCheckingExisting = false;
    });
  }

  /// Accepts any reasonably-formed http(s) URL. We don't restrict to
  /// Google Drive / LinkedIn specifically since applicants may paste
  /// Dropbox, personal site, or other portfolio links too.
  String? _validateResumeLink(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please paste a link to your resume/CV';
    final uri = Uri.tryParse(v);
    if (uri == null || !uri.isAbsolute || !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return 'Enter a valid link starting with http:// or https://';
    }
    return null;
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showSnackBar('You need to be logged in to apply.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Write the application document. Field names match what
      // ApplicationsScreen expects: applicantId, appliedAt, status,
      // opportunityTitle, startupName. resumeLink replaces the old
      // uploaded-file resumeUrl/resumeFileName fields.
      await FirebaseFirestore.instance.collection('applications').add({
        'applicantId': userId,
        'opportunityId': widget.opportunityId,
        'opportunityTitle': widget.opportunityTitle,
        'startupName': widget.startupName,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'fullName': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'linkedIn': _linkedInController.text.trim(),
        'coverLetter': _coverLetterController.text.trim(),
        'resumeLink': _resumeLinkController.text.trim(),
      });

      if (!mounted) return;
      _showSnackBar('Application submitted successfully!');
      Navigator.pop(context, true); // return true so caller can refresh UI
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Something went wrong: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textDark),
        title: const Text(
          'Apply',
          style: TextStyle(color: _textDark, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _isCheckingExisting
          ? const Center(child: CircularProgressIndicator(color: _primaryBlue))
          : _alreadyApplied
              ? _buildAlreadyAppliedState()
              : _buildForm(),
    );
  }

  Widget _buildAlreadyAppliedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 56, color: _primaryBlue),
            const SizedBox(height: 16),
            const Text(
              'You\'ve already applied',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'You already have an application in for ${widget.opportunityTitle} at ${widget.startupName}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _textGrey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOpportunitySummary(),
          const SizedBox(height: 24),
          _sectionLabel('Full Name'),
          _textField(
            controller: _nameController,
            hint: 'Your full name',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
          ),
          const SizedBox(height: 16),
          _sectionLabel('Email'),
          _textField(
            controller: _emailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _sectionLabel('Phone Number'),
          _textField(
            controller: _phoneController,
            hint: '+250 7XX XXX XXX',
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
          ),
          const SizedBox(height: 16),
          _sectionLabel('LinkedIn / Portfolio (optional)'),
          _textField(
            controller: _linkedInController,
            hint: 'https://linkedin.com/in/...',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _sectionLabel('Resume / CV Link'),
          _textField(
            controller: _resumeLinkController,
            hint: 'Paste a Google Drive, Dropbox, or portfolio link',
            keyboardType: TextInputType.url,
            validator: _validateResumeLink,
            prefixIcon: Icons.link_rounded,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Make sure sharing is set to "Anyone with the link can view".',
              style: TextStyle(fontSize: 11.5, color: _textGrey),
            ),
          ),
          const SizedBox(height: 16),
          _sectionLabel('Why are you a good fit?'),
          _textField(
            controller: _coverLetterController,
            hint: 'Tell us briefly why you\'re a strong match for this role...',
            maxLines: 5,
            validator: (v) =>
                (v == null || v.trim().length < 20) ? 'Please write at least a couple of sentences' : null,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                disabledBackgroundColor: _primaryBlue.withOpacity(0.6),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Submit Application',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOpportunitySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline_rounded, color: _primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.opportunityTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.startupName,
                  style: const TextStyle(fontSize: 13, color: _textGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: const Color(0xFF94A3B8)) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),
    );
  }
}