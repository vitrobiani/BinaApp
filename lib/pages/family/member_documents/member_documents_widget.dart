import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/app_state.dart';
import '/backend/schema/structs/index.dart';
import '/bina_design/bina_design.dart';
import '/components/dialogs/confirm_dialog.dart';
import '/services/member_document_service.dart';

class MemberDocumentsWidget extends StatefulWidget {
  const MemberDocumentsWidget({
    super.key,
    required this.familyMemberId,
    this.familyMemberName,
  });

  static String routeName = 'MemberDocuments';
  static String routePath = 'memberDocuments';

  final String familyMemberId;
  final String? familyMemberName;

  @override
  State<MemberDocumentsWidget> createState() => _MemberDocumentsWidgetState();
}

class _MemberDocumentsWidgetState extends State<MemberDocumentsWidget> {
  bool _isBusy = false;
  AttachProgress? _progress;

  @override
  void initState() {
    super.initState();
    // Ensure the in-memory list is fresh — the chat flow may have hydrated
    // for a different member.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState().loadMemberDocuments(widget.familyMemberId);
    });
  }

  Future<void> _upload() async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _progress = null;
    });
    try {
      final picked = await MemberDocumentService.instance.pickAndExtract();
      if (picked == null) return;
      await MemberDocumentService.instance.attachToMember(
        familyMemberId: widget.familyMemberId,
        doc: picked,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      final msg = picked.extractionStatus == 'empty'
          ? '${picked.fileName} attached, but no readable text was found (scanned image?).'
          : '${picked.fileName} attached.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _delete(MemberDocumentStruct doc) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete document?',
      message: '${doc.fileName} will no longer be visible to Gemma.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await MemberDocumentService.instance.deleteFromMember(doc);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BinaColors.surfaceAlt,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (_progress != null) _buildProgressBar(_progress!),
            Expanded(
              child: AnimatedBuilder(
                animation: AppState(),
                builder: (context, _) => _buildBody(AppState().memberDocuments),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isBusy ? null : _upload,
        backgroundColor: BinaColors.primary,
        foregroundColor: BinaColors.surface,
        icon: _isBusy
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: BinaColors.surface,
                ),
              )
            : const Icon(Icons.upload_file_rounded),
        label: Text(_isBusy ? 'Uploading…' : 'Upload PDF'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          BinaIconButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.familyMemberName != null
                  ? 'Documents — ${widget.familyMemberName}'
                  : 'Member documents',
              style: BinaType.titleLg,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AttachProgress p) {
    final label = switch (p.stage) {
      AttachStage.saving => 'Saving document…',
      AttachStage.embedding => 'Embedding chunk ${p.current + 1} / ${p.total}',
      AttachStage.done => 'Done',
    };
    final value = p.total == 0 ? null : (p.current + 1) / p.total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: BinaType.bodySm.copyWith(color: BinaColors.ink2)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p.stage == AttachStage.embedding ? value : null,
              minHeight: 6,
              backgroundColor: BinaColors.surface,
              color: BinaColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<MemberDocumentStruct> docs) {
    if (docs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_rounded, size: 56, color: BinaColors.ink3),
              const SizedBox(height: 12),
              Text('No documents yet', style: BinaType.titleMd),
              const SizedBox(height: 6),
              Text(
                'Upload PDFs like prior reports or referral letters and Gemma will reference them in this member\'s chats.',
                style: BinaType.bodyMd.copyWith(color: BinaColors.ink2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _DocumentTile(
        doc: docs[i],
        onDelete: () => _delete(docs[i]),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.doc, required this.onDelete});

  final MemberDocumentStruct doc;
  final VoidCallback onDelete;

  String _formatSize(int? bytes) {
    if (bytes == null) return '—';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return DateFormat('d MMM yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final isReady = doc.extractionStatus == 'ok';
    final badgeColor = isReady ? BinaColors.success : BinaColors.warning;
    final badgeLabel = isReady ? 'Ready' : 'No text';

    return Dismissible(
      key: ValueKey(doc.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: BinaColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_rounded, color: BinaColors.surface),
      ),
      confirmDismiss: (_) async {
        onDelete();
        // We handle the actual removal via AppState, so tell Dismissible
        // not to remove the widget itself — the AnimatedBuilder rebuild
        // will drop it.
        return false;
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: BinaColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BinaColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: BinaColors.primary100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.picture_as_pdf_rounded,
                  color: BinaColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.fileName,
                    style: BinaType.titleSm,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatSize(doc.byteSize)} · ${_formatDate(doc.uploadedAt)}',
                    style:
                        BinaType.labelSm.copyWith(color: BinaColors.ink3),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(BinaRadius.pill),
              ),
              child: Text(
                badgeLabel,
                style: BinaType.labelSm.copyWith(color: badgeColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
