
import 'package:flutter/material.dart';
import '/models/student_response.dart';
import '/models/parent_feedback.dart';
import '/services/parent_feedback_service.dart';

class ParentFeedbackScreen extends StatefulWidget {
  final StudentResponse? student;

  const ParentFeedbackScreen({
    super.key,
    this.student,
  });

  @override
  State<ParentFeedbackScreen> createState() =>
      _ParentFeedbackScreenState();
}

class _ParentFeedbackScreenState extends State<ParentFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _type = 'COMPLAINT';
  bool _isSubmitting = false;

  bool get _hasFeedback =>
      _subjectController.text.trim().isNotEmpty ||
      _messageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    _subjectController.addListener(_onFeedbackChanged);
    _messageController.addListener(_onFeedbackChanged);
  }

  void _onFeedbackChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _subjectController.removeListener(_onFeedbackChanged);
    _messageController.removeListener(_onFeedbackChanged);

    _subjectController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);

    try {
      final feedback = ParentFeedback(
        type: _type,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        studentId: widget.student?.id,
      );

      final response =
          await ParentFeedbackService.submitFeedback(feedback);

      if (!mounted) return;

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        _subjectController.clear();
        _messageController.clear();

        setState(() => _type = 'COMPLAINT');

        _showSuccessDialog();
      } else {
        _showErrorDialog(
          'Submission Failed',
          'We could not submit your feedback '
          '(Error ${response.statusCode}). Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        'Something Went Wrong',
        'Unable to submit your feedback. '
        'Please check your internet connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 12,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7EE),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.12),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF16A36A),
                    size: 54,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Submitted Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thank you for sharing your feedback. '
                  'Your message has been submitted to '
                  'the school admin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2864C5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFD92D20),
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2864C5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2864C5);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Complaints & Suggestions',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2939),
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2864C5),
                      Color(0xFF6295EC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.feedback_outlined,
                      color: Colors.white,
                      size: 42,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We value your feedback',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Share a concern or an idea to help us improve.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Feedback type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _TypeCard(
                      title: 'Complaint',
                      subtitle: 'Report a concern',
                      icon: Icons.report_problem_outlined,
                      selected: _type == 'COMPLAINT',
                      onTap: () {
                        setState(() => _type = 'COMPLAINT');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeCard(
                      title: 'Suggestion',
                      subtitle: 'Share an idea',
                      icon: Icons.lightbulb_outline_rounded,
                      selected: _type == 'SUGGESTION',
                      onTap: () {
                        setState(() => _type = 'SUGGESTION');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Subject',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 9),

              TextFormField(
                controller: _subjectController,
                maxLength: 150,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  hint: 'Enter a short subject',
                  icon: Icons.short_text_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }

                  if (value.trim().length > 150) {
                    return 'Subject cannot exceed 150 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 9),

              TextFormField(
                controller: _messageController,
                minLines: 5,
                maxLines: 8,
                maxLength: 3000,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(
                  hint: 'Describe your complaint or suggestion...',
                  icon: Icons.notes_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the details';
                  }

                  if (value.trim().length > 3000) {
                    return 'Details cannot exceed 3000 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 10),

              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your submission will be available to the school admin.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              if (_hasFeedback) ...[
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF98A2B3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 19),
                              SizedBox(width: 9),
                              Text(
                                'Submit Feedback',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF667085),
      ),
      filled: true,
      fillColor: Colors.white,
      counterStyle: const TextStyle(fontSize: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Color(0xFF2864C5),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2864C5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEAF1FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? primary
                : const Color(0xFFE4E7EC),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected
                  ? primary
                  : const Color(0xFF667085),
              size: 25,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected
                    ? primary
                    : const Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
