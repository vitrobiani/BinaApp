import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app_core/app_util.dart';
import '/bina_design/bina_design.dart';
import 'help_support_model.dart';

export 'help_support_model.dart';

class HelpSupportWidget extends StatefulWidget {
  const HelpSupportWidget({super.key});

  static String routeName = 'HelpSupport';
  static String routePath = 'helpSupport';

  @override
  State<HelpSupportWidget> createState() => _HelpSupportWidgetState();
}

class _HelpSupportWidgetState extends State<HelpSupportWidget> {
  late HelpSupportModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const String _supportEmail = 'support@bina-system.com';
  static const String _supportPhone = '+972 50 123 4567';

  List<Map<String, String>> _getFaqItems(BuildContext context) => [
    {
      'question': AppLocalizations.of(context).getText('help_faq_q1'),
      'answer': AppLocalizations.of(context).getText('help_faq_a1'),
    },
    {
      'question': AppLocalizations.of(context).getText('help_faq_q2'),
      'answer': AppLocalizations.of(context).getText('help_faq_a2'),
    },
    {
      'question': AppLocalizations.of(context).getText('help_faq_q3'),
      'answer': AppLocalizations.of(context).getText('help_faq_a3'),
    },
    {
      'question': AppLocalizations.of(context).getText('help_faq_q4'),
      'answer': AppLocalizations.of(context).getText('help_faq_a4'),
    },
  ];

  int _openFaqIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HelpSupportModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'Bina System Support Request'},
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _supportPhone.replaceAll(' ', ''));
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _submitFeedback() {
    if (_model.feedbackController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getText('help_enter_feedback')),
          backgroundColor: BinaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).getText('help_thank_you')),
        backgroundColor: BinaColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    _model.feedbackController?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: BinaColors.surfaceAlt,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 12,
              bottom: 40,
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    BinaIconButton(
                      icon: Icons.chevron_left_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).getText('help_title'),
                          style: BinaType.titleMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ).animate()
                  .fadeIn(duration: 300.ms)
                  .moveY(begin: -10, end: 0, duration: 300.ms),

              const SizedBox(height: 16),

              // Contact Section
              _SettingsSection(
                title: AppLocalizations.of(context).getText('help_contact'),
                child: Column(
                  children: [
                    _ContactRow(
                      icon: Icons.email_outlined,
                      iconBgColor: BinaColors.primary100,
                      iconColor: BinaColors.primary700,
                      label: AppLocalizations.of(context).getText('help_email'),
                      subtitle: _supportEmail,
                      onTap: _launchEmail,
                      showBorder: true,
                    ),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      iconBgColor: BinaColors.aqua100,
                      iconColor: BinaColors.aqua700,
                      label: AppLocalizations.of(context).getText('help_phone'),
                      subtitle: _supportPhone,
                      onTap: _launchPhone,
                    ),
                  ],
                ),
              ).animate()
                  .fadeIn(delay: 100.ms, duration: 400.ms)
                  .moveY(begin: 20, end: 0, delay: 100.ms, duration: 400.ms),

              // FAQ Section
              _SettingsSection(
                title: AppLocalizations.of(context).getText('help_faq'),
                child: Builder(
                  builder: (context) {
                    final faqItems = _getFaqItems(context);
                    return Column(
                      children: faqItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    final isOpen = _openFaqIndex == index;
                    final isLast = index == faqItems.length - 1;

                    return _FaqItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
                      isOpen: isOpen,
                      isLast: isLast,
                      onToggle: () {
                        setState(() {
                          _openFaqIndex = isOpen ? -1 : index;
                        });
                      },
                    );
                  }).toList(),
                    );
                  },
                ),
              ).animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms),

              // Send Feedback Section
              _SettingsSection(
                title: AppLocalizations.of(context).getText('help_send_feedback'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextField(
                        controller: _model.feedbackController,
                        maxLines: 4,
                        style: BinaType.bodyMd,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).getText('help_feedback_hint'),
                          hintStyle: BinaType.bodyMd.copyWith(color: BinaColors.ink3),
                          filled: true,
                          fillColor: BinaColors.surface,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BinaColors.lineStrong),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BinaColors.lineStrong),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: BinaColors.primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      BinaButton(
                        label: AppLocalizations.of(context).getText('help_submit_feedback'),
                        variant: BinaButtonVariant.primary,
                        fullWidth: true,
                        onPressed: _submitFeedback,
                      ),
                    ],
                  ),
                ),
              ).animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .moveY(begin: 20, end: 0, delay: 300.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SETTINGS SECTION
// ═══════════════════════════════════════════════════════════════

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: BinaType.overline.copyWith(
                color: BinaColors.ink3,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: BinaColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: BinaColors.line),
              boxShadow: BinaElevation.sh2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CONTACT ROW
// ═══════════════════════════════════════════════════════════════

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.showBorder = false,
  });

  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(bottom: BorderSide(color: BinaColors.line))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: BinaType.bodyLg),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: BinaColors.ink3, size: 18),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FAQ ITEM
// ═══════════════════════════════════════════════════════════════

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isOpen,
    required this.isLast,
    required this.onToggle,
  });

  final String question;
  final String answer;
  final bool isOpen;
  final bool isLast;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: BinaType.bodyLg.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: BinaColors.surfaceSunken,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: BinaColors.ink2,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Text(
              answer,
              style: BinaType.bodyMd.copyWith(
                color: BinaColors.ink2,
                height: 1.55,
              ),
            ),
          ),
          crossFadeState: isOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (!isLast)
          Divider(height: 1, color: BinaColors.line),
      ],
    );
  }
}
