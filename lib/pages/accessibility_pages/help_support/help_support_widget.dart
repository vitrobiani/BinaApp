import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app_core/app_theme.dart';
import '/app_core/app_util.dart';
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

  // Placeholder generic contact info for now
  static const String _supportEmail = 'support@bina-system.com';
  static const String _supportPhone = '+972501234567';

  // Placeholder generic FAQ items for now
  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I start a dental scan?',
      'answer': 'Navigate to the Diagnose tab, select a family member, and follow the on-screen instructions to capture images of your teeth.',
    },
    {
      'question': 'How accurate are the scan results?',
      'answer': 'Our AI-powered analysis provides preliminary assessments. For definitive diagnosis, always consult with a dental professional.',
    },
    {
      'question': 'Can I add multiple family members?',
      'answer': 'Yes! Go to the Family section from the home screen to add and manage family members. Each member has their own scan history.',
    },
    {
      'question': 'How do I change the app language?',
      'answer': 'Go to Profile → Preferences and Accessibility → Language and Region to select your preferred language.',
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Yes, all your data is encrypted and stored securely. We do not share your personal health information with third parties.',
    },
  ];

  // Placeholder generic tutorial items for now
  static const List<Map<String, dynamic>> _tutorialItems = [
    {
      'title': 'Getting Started',
      'description': 'Learn the basics of using Bina System',
      'icon': Icons.play_circle_outline,
    },
    {
      'title': 'Taking Your First Scan',
      'description': 'Step-by-step guide to dental scanning',
      'icon': Icons.camera_alt_outlined,
    },
    {
      'title': 'Understanding Results',
      'description': 'How to interpret your scan results',
      'icon': Icons.analytics_outlined,
    },
    {
      'title': 'Managing Family Members',
      'description': 'Add and track multiple family members',
      'icon': Icons.family_restroom,
    },
  ];

  // Feedback categories
  String _selectedCategory = 'General Feedback';
  static const List<String> _feedbackCategories = [
    'General Feedback',
    'Bug Report',
    'Feature Request',
    'Question',
    'Other',
  ];

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
      queryParameters: {
        'subject': 'Bina System Support Request',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _supportPhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitFeedback() {
    if (_model.feedbackController?.text.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your feedback'),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
      return;
    }

    // Placeholder - would send to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: AppTheme.of(context).success,
      ),
    );
    _model.feedbackController?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).secondaryBackground,
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.of(context).primaryText,
            size: 24.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Help and Support',
          style: AppTheme.of(context).headlineSmall,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Us Section
              _buildSectionHeader('Contact Us'),
              _buildContactCard(),

              const SizedBox(height: 24.0),

              // Send Feedback Section
              _buildSectionHeader('Send Feedback'),
              _buildFeedbackForm(),

              const SizedBox(height: 24.0),

              // FAQ Section
              _buildSectionHeader('Frequently Asked Questions'),
              _buildFaqSection(),

              const SizedBox(height: 24.0),

              // Tutorials Section
              _buildSectionHeader('Tutorials & Guides'),
              _buildTutorialsSection(),

              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
      child: Text(
        title,
        style: AppTheme.of(context).titleSmall.override(
              font: GoogleFonts.inter(),
              color: AppTheme.of(context).primaryText,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.of(context).alternate),
        ),
        child: Column(
          children: [
            // Email row
            InkWell(
              onTap: _launchEmail,
              onLongPress: _copyEmail,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        color: AppTheme.of(context).primary,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _supportEmail,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.of(context).secondaryText,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              height: 1,
              color: AppTheme.of(context).alternate,
            ),
            // Phone row
            InkWell(
              onTap: _launchPhone,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: AppTheme.of(context).success,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone',
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            _supportPhone,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.of(context).secondaryText,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.of(context).alternate),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category dropdown
            Text(
              'Category',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppTheme.of(context).alternate),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  items: _feedbackCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: AppTheme.of(context).bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            // Message field
            Text(
              'Message',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.inter(),
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _model.feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                hintStyle: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.inter(),
                      color: AppTheme.of(context).secondaryText,
                    ),
                filled: true,
                fillColor: AppTheme.of(context).primaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: AppTheme.of(context).alternate),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: AppTheme.of(context).alternate),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: AppTheme.of(context).primary),
                ),
              ),
              style: AppTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 16.0),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Submit Feedback',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: AppTheme.of(context).alternate),
        ),
        child: Column(
          children: List.generate(_faqItems.length, (index) {
            final item = _faqItems[index];
            final isExpanded = _model.isFaqExpanded(index);
            final isLast = index == _faqItems.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _model.toggleFaqItem(index));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['question']!,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    child: Text(
                      item['answer']!,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: AppTheme.of(context).alternate,
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTutorialsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _tutorialItems.map((tutorial) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                // Placeholder - would navigate to tutorial
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tutorial['title']} - Coming soon!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppTheme.of(context).alternate),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        tutorial['icon'] as IconData,
                        color: AppTheme.of(context).primary,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutorial['title'] as String,
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            tutorial['description'] as String,
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(),
                                  color: AppTheme.of(context).secondaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.of(context).secondaryText,
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
