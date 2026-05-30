import '/backend/schema/enums/enums.dart';
import '/bina_design/bina_design.dart';
import '/app_core/app_util.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'family_row_detail_model.dart';
export 'family_row_detail_model.dart';

class FamilyRowDetailWidget extends StatefulWidget {
  const FamilyRowDetailWidget({
    super.key,
    required this.name,
    this.score,
    this.profilePic,
    required this.lastChecked,
    required this.gender,
    required this.age,
  });

  final String? name;
  final double? score;
  final AppUploadedFile? profilePic;
  final DateTime? lastChecked;
  final Genders? gender;
  final int? age;

  @override
  State<FamilyRowDetailWidget> createState() => _FamilyRowDetailWidgetState();
}

class _FamilyRowDetailWidgetState extends State<FamilyRowDetailWidget> {
  late FamilyRowDetailModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FamilyRowDetailModel());
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

  String _formatLastChecked(DateTime? date) {
    if (date == null) return 'Never';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: BinaColors.surface,
        border: Border(
          bottom: BorderSide(color: BinaColors.line),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 300),
                imageUrl:
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Name and last checked
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    valueOrDefault<String>(widget.name, 'Family Member')
                        .maybeHandleOverflow(maxChars: 32, replacement: '...'),
                    style: BinaType.titleSm,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Last checked: ${_formatLastChecked(widget.lastChecked)}',
                    style: BinaType.bodySm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            // Score
            if (widget.score != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.score! >= 80
                      ? BinaColors.success100
                      : widget.score! >= 50
                          ? BinaColors.warning.withValues(alpha: 0.1)
                          : BinaColors.error100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.score!.toStringAsFixed(0)}%',
                  style: BinaType.labelMd.copyWith(
                    color: widget.score! >= 80
                        ? BinaColors.success
                        : widget.score! >= 50
                            ? BinaColors.warning
                            : BinaColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            // Desktop button
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
            )) ...[
              const SizedBox(width: 12),
              BinaButton(
                label: AppLocalizations.of(context).getText('yhtoc3s4'),
                variant: BinaButtonVariant.primary,
                onPressed: () {
                  // Navigate to diagnostics
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
